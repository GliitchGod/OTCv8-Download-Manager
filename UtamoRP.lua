setDefaultTab("A")
storage.castBelowHp = "100"
storage.deactiveBelowMana = "0"

function updateValues()
    castBelowHp = tonumber(storage.castBelowHp) or 100
    deactiveBelowMana = tonumber(storage.deactiveBelowMana) or 0
end

updateValues()

macro(100, "advanced manashield", function()
    -- Update the values within the macro
    updateValues()
    
    if canCast("utamo vita") then
        if hppercent() <= castBelowHp and manapercent() >= deactiveBelowMana and not hasManaShield() then
            say('utamo vita')
        end
    end
    
    if canCast("utamo vita") then
        if manapercent() <= deactiveBelowMana and hppercent() >= castBelowHp and hasManaShield() then
            say('utamo vita')
        end
    end
end)

addTextEdit("castBelowHp", storage.castBelowHp or "0", function(widget, text)
    storage.castBelowHp = text
end)

addTextEdit("deactiveBelowMana", storage.deactiveBelowMana or "0", function(widget, text)
    storage.deactiveBelowMana = text
end)

updateValues()
