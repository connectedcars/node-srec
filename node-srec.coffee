#!/usr/bin/env coffee
#encoding: UTF-8
fs = require('fs');
request = require('request');


module.exports.parseSrec = parseSrec = (data) ->
  mem={}
  info=""
  min=max=boot=null

  srecs=data.split("\n")
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

cache={}

module.exports.readSrecFile = (fn,cb) ->
  if cache[fn]
    console.log "node-srec: from Cache File: '#{fn}'"
    cb cache[fn]
  else
    console.log "node-srec: Reading File: '#{fn}'"
    fs.readFile fn, 'utf8', (error,data) ->
      cache[fn]=parseSrec data
      cb cache[fn]

module.exports.readSrecUrl = (url,cb) ->
  if cache[url]
    console.log "node-srec: from Cache Url: '#{url}'"
    cb cache[url]
  else
    console.log "node-srec: Getting Url: '#{url}'"
    request.get url, (error, response, body) ->
      if not error and response.statusCode is 200
        cache[url]= parseSrec body
        cb cache[url]
      else
        cb []

module.exports.blockify  = (data,min,max,size) ->
  blks={}
  console.log "node-srec: Blockify",min.toString(16),max.toString(16),size
  donee=false
  for as,b of data.recs
    a=parseInt as
    len=b.length
    #console.log len,a.toString(16)
    for i in [0...len]
      if a+i>max or a+i<min
        if not donee
          console.log "Error -- out of range: #{(a+i).toString(16)} [#{min.toString(16)}..#{max.toString(16)}]"
          donee=true
        continue
      blk=Math.floor((a+i-min)/size)
      oset=(a+i-min)%size
      #console.log "blk: #{blk} oset: #{oset}"
      if not blks[blk]
        blks[blk]=Array.apply(null, new Array(size)).map(Number.prototype.valueOf,0);
      if b[i]==undefined
        console.log "????? ",i,len
      blks[blk][oset]=b[i]
      #console.log a+i
    #console.log blks
  blks
