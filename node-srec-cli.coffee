#!/usr/bin/env coffee
#encoding: UTF-8
srec = require('node-srec');
#srec = require('./node-srec.js');
sprintf = require('sprintf').sprintf;

if false
  srec.readSrecUrl "https://s3-eu-west-1.amazonaws.com/static.lnx.fi/sol_STM32L_mg11.srec" , (data) ->
    console.log "data:",data
    bl=srec.blockify data,0x08000000,0x08010000,64
    for a,b of bl
      s=sprintf "%08X:",parseInt(a)
      for byte in b
        s+=sprintf "%02X ",byte
      console.log s

srec.readSrecFile "/home/arisi/projects/mygit/arisi/ctex_apps/bin/appi.srec" , (data) ->
  bl=srec.blockify data,0x0801f000,0x08020000,64
  for a,b of bl
    s=sprintf "%08X:",parseInt(a)
    for byte in b
      s+=sprintf "%02X ",byte
    console.log s

  srec.readSrecFile "/home/arisi/projects/mygit/arisi/ctex_apps/bin/appi.srec" , (data) ->
    bl=srec.blockify data,0x0801f000,0x08020000,64
    for a,b of bl
      s=sprintf "%08X:",parseInt(a)
      for byte in b
        s+=sprintf "%02X ",byte
      console.log s

