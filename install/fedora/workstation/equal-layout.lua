-- Equal-size tiles, using Hyprland's native Lua layout API.
hl.layout.register("omadora-equal", {
  recalculate = function(ctx)
    local n = #ctx.targets
    if n == 0 then return end
    local columns = n <= 3 and n or math.ceil(math.sqrt(n))
    for i, target in ipairs(ctx.targets) do
      target:place(ctx:grid_cell(i, columns))
    end
  end,
})
