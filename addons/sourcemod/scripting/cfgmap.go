/**
 * cfgmap.go
 * 
 * Copyright 2020 Nirari Technologies, Alliedmodders LLC.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 */

package main

import (
	"sourcemod"
	"datapack"
)

type KeyValType int
const (
	KeyValType_Null = 0     /// nil
	KeyValType_Section  /// StringMap : char[*][*]
	KeyValType_Value    /// char[*]
)

const SEC_SCOPE_SIZE = 512

type PackVal struct {
	data DataPack
	size int
	tag KeyValType
}


type ConfigMap StringMap

/// __sp__(`cfg = new ConfigMap(filename);`)

func (ConfigMap) GetVal(key string, valbuf *PackVal) bool
func (ConfigMap) GetSize(key_path string) int
func (ConfigMap) Get(key_path string, buffer []char, buf_size int) int
func (ConfigMap) GetSection(key_path string) ConfigMap
func (ConfigMap) GetKeyValType(key_path string) KeyValType
func (ConfigMap) GetInt(key_path string, i *int, base int) int
func (ConfigMap) GetFloat(key_path string, f *float) int
func (ConfigMap) GetBool(key_path string, b *bool, simple bool) int

func ParseTargetPath(key string, buffer []char, buffer_len int) bool
func DeleteCfg(cfg *ConfigMap, clear_only bool)
func PrintCfg(cfg ConfigMap)