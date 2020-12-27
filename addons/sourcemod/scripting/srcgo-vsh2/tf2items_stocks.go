/**
 * tf2items_stocks.go
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

import "sourcemod"


type TF2Item struct {
	iFlags, iItemIndex, iQuality, iLevel, iNumAttribs int
}

func (TF2Item) GiveNamedItem(client Entity) Entity
func (TF2Item) SetClassname(classname string)
func (TF2Item) GetClassname(strDest []char, iDestSize int)
func (TF2Item) SetAttribute(iSlotIndex, iAttribDefIndex int, flValue float)
func (TF2Item) GetAttribID(iSlotIndex int) int
func (TF2Item) GetAttribValue(iSlotIndex int) float

func TF2Item_PrepareItemHandle(hItem TF2Item, name []char, index int, att string, dontpreserve bool) TF2Item