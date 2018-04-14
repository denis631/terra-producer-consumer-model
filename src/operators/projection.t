-- Projection
Projection = Operator:newChildClass()

function Projection:new(child, requiredIUs)
    local p = Projection.parentClass.new(self)
    p.child = child
    p.requiredIUs = requiredIUs
    return p
end

function Projection:prepare()
    self.attrTypes = {}

    for _, iu in ipairs(self.requiredIUs) do
        for attrName, attrType in pairs(iu) do
            table.insert(self.attrTypes, attrType)
        end
    end

    self.child:prepare(self)
end

function Projection:produce()
    return self.child:produce()
end

function createFormatString(attrTypes)
    local function formatForType(type)
        -- TODO: add more cases for other types if needed, strings, dates, doubles, etc.
        if type ==  int then
            return "%d"
        elseif type == double then
            return "%f"
        elseif type == rawstring then
            return "%s"
        end
    end

    local formatString = "| "

    for _,attrType in ipairs(attrTypes) do
        formatString = formatString .. formatForType(attrType) .. " | "
    end

    return formatString .. "\n"
end

function Projection:consume()
    local formatString = createFormatString(self.attrTypes)

    return macro(function(attributes)
        return quote 
            C.printf(formatString, attributes)
        end
    end)
end