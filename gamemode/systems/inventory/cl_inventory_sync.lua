netstream.Hook("dbt.Sync.items", function(tbl)
	dbt.inventory.items = tbl
end)