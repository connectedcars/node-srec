#!/usr/bin/env coffee
#encoding: UTF-8

srec = require('./node-srec.js');

fn="/home/arisi/projects/mygit/arisi/ctex_apps/bin/appi.srec"
fn="/home/arisi/projects/mygit/arisi/ctex/bin/sol_STM32L_mg11.srec"

data=srec.readSrecFile(fn)
console.log data
