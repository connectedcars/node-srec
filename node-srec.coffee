#!/usr/bin/env coffee
#encoding: UTF-8
fs = require('fs');

fn="/home/arisi/projects/mygit/arisi/ctex_apps/bin/appi.srec"

module.exports.readSrecFile = (fn) ->
  mem={}
  boot=null
  info=""
  min=null
  max=null

  srecs=fs.readFileSync(fn, 'utf8').split("\n")
  for s in srecs
    if s[0]=="S"
      switch type=parseInt(s[1])
        when 0,1,9,5 then alen=2
        when 2,6,8 then alen=3
        when 3,7 then alen=4
        else continue
      addr=parseInt(s[4...4+alen*2],16)
      dp=4+alen*2
      b=[]
      len=parseInt(s[2...4],16)
      for i in [alen+2..len]
        b.push parseInt(s[i*2..i*2+1],16)
      switch type
        when 1,2,3
          mem[addr]=b
          min=addr if not min or addr < min
          max=addr if not max or addr+b.length > max
        when 7,8,9
          boot=addr
        when 0
          for byte in b
            info+=String.fromCharCode(byte)
  return {recs: mem, min: min, max: max, boot: boot, info: info}
