

function init()
  connect(Creature, {
    onAppear = onAppear,
  })
end

function terminate()
  disconnect(Creature, {
    onAppear = onAppears,
  })
end

function onAppear(creature)
  creature:setInformationOffset(-3, -18)
end
