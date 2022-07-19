#!/usr/bin/python3
import random
import os
array=["Boltzmann", "Vltava", "Jardin", "Wurstchen", "Grafton", 
	  "Duomo", "Tulip", "Vistula", "Ikea", "Lindenhof", "Custard",
	  "Ghost", "Phooey", "Drift", "Marina Bay", "Han River", "station"]

arr_length = len(array)
choose_rand = random.randint(0, len(array))
item_to_choose = array[choose_rand]
command = "windscribe-cli connect '{}'".format(item_to_choose)
os.system(command)
