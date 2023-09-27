SETUP:

# QB-Inventory
```lua
['vehiclekey'] 				 	 = {['name'] = 'vehiclekey',					['label'] = 'Vehicle key', 				['weight'] = 0, 		['type'] = 'item', 		['image'] = 'vehiclekeys.png', 				['unique'] = true, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = "This is a car key, take good care of it, if you lose it you probably won't be able to use your car"}
```
```js
else if (itemData.name == "vehiclekey") {
    $(".item-info-title").html(itemData.info.label);
}
```

# Ox_Invntory
```lua
["vehiclekey"] = {
	label = "Vehicle Key",
	weight = 0,
	stack = false,
	close = false,
	description = "A vehicle key to lock and unlock your vehicle",
}
```


EVENTS:

# Add Permanent Key (item)
"vehiclekeys:client:giveKeyItem" -- Client Event (params: plate, vehicleId)

# Add Temporary Key
"vehiclekeys:server:AcquireTempVehicleKeys" -- Server Event (params: plate)

# Remove Permanent Key (item)
"vehiclekeys:client:removeKeyItem" -- Client Event (params: plate, vehicleId)


COMMANDS:

/givetempkeys [id] [plate] -- Give temporary keys to a player or self (admin only)
/removetempkeys [id] [plate] -- Remove temporary keys from a player or self (admin only)
/givekeys -- Give permanent keys to a vehicle (Police or Cardealer)