/*
Copyright 2015 The Camlistore Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// TODO(mpl): doc
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"

	"camlistore.org/pkg/jsonsign"
	"camlistore.org/pkg/osutil"
	"camlistore.org/pkg/types/serverconfig"
	"camlistore.org/pkg/wkfs"
)

var (
	flagUsername = flag.String("username", "", "username for accessing the Camlistore web UI")
	flagPassword = flag.String("password", "", "password for accessing the Camlistore web UI")
)

const (
	camliServerConf = "/home/camli/.config/camlistore/server-config.json"
)

var baseConfig = serverconfig.Config{
	Listen: ":3179",
	HTTPS:  true,
    BlobPath: "/home/camli/var/camlistore/blobs",
	PackRelated: true,
	MySQL: "root@localhost:3306:",
	DBNames: map[string]string{
		"queue-sync-to-index": "sync_index_queue",
		"ui_thumbcache": "ui_thumbmeta_cache",
		"blobpacked_index": "blobpacked_index",
	},
}

// TODO(mpl): export camlistore.org/pkg/serverinit/genconfig.go:getOrMakeKeyring so we can just use it here.
func getOrMakeKeyring() (keyID, secRing string, err error) {
	secRing = osutil.SecretRingFile()
	_, err = wkfs.Stat(secRing)
	switch {
	case err == nil:
		keyID, err = jsonsign.KeyIdFromRing(secRing)
		if err != nil {
			err = fmt.Errorf("Could not find any keyID in file %q: %v", secRing, err)
			return
		}
		log.Printf("Re-using identity with keyID %q found in file %s", keyID, secRing)
	case os.IsNotExist(err):
		keyID, err = jsonsign.GenerateNewSecRing(secRing)
		if err != nil {
			err = fmt.Errorf("Could not generate new secRing at file %q: %v", secRing, err)
			return
		}
		log.Printf("Generated new identity with keyID %q in file %s", keyID, secRing)
	default:
		err = fmt.Errorf("Could not stat secret ring %q: %v", secRing, err)
	}
	return
}

func writeDefaultConfigFile() error {
	if err := wkfs.MkdirAll(baseConfig.BlobPath, 0700); err != nil {
		return fmt.Errorf("Could not create default blobs directory: %v", err)
	}

	keyID, secretRing, err := getOrMakeKeyring()
	if err != nil {
		return err
	}
	baseConfig.Identity = keyID
	baseConfig.IdentitySecretRing = secretRing
	baseConfig.Auth = fmt.Sprintf("userpass:%s:%s", *flagUsername, *flagPassword)

	confData, err := json.MarshalIndent(baseConfig, "", "    ")
	if err != nil {
		return fmt.Errorf("Could not json encode config file : %v", err)
	}
	if err := wkfs.WriteFile(camliServerConf, confData, 0600); err != nil {
		return fmt.Errorf("Could not create or write default server config: %v", err)
	}

	return nil
}

func checkArgs() {
	if *flagUsername == "" {
		fmt.Println("Please provide a username")
		flag.Usage()
		os.Exit(1)
	}
	if *flagPassword == "" {
		fmt.Println("Please provide a password")
		flag.Usage()
		os.Exit(1)
	}
}

func main() {
	flag.Parse()

	checkArgs()

	if _, err := os.Stat(camliServerConf); err == nil {
		fmt.Printf("Configuration file %v already exists, nothing to do.\n", camliServerConf)
		return
	} else {
		if !os.IsNotExist(err) {
			log.Fatal(err)
		}
	}
	
	if err := writeDefaultConfigFile(); err != nil {
		log.Fatal(err)
	}
}
