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