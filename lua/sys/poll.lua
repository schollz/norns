--- Poll class;
-- API for receiving values from audio system.
-- @module poll
-- @alias Poll

Poll = {}
Poll.__index = Poll

-- constructor
function Poll.new(props)
   local self = setmetatable({}, Poll)
   if props then
      if props.id && props.name then
	 self.props = props
	 return self
      end
   end
   print("warning: Poll constructor requires at least name and id properties")
   return nil
end


--- Instance Methods
-- @section instance

--- start a poll
function Poll:start()
   start_poll(self.id)
end

--- stop a poll
function Poll:stop()
   stop_poll(self.id)
end


--- custom setters
--- FIXME: need explicit tags or something for ldoc
function Poll:__newindex(idx, val)
   if idx == 'time' then
      self.props[time] = val
      set_poll_time(self.props.id, val)
   elseif idx == 'callback' then
      self.props.callback = val
   end
   -- oher properties are not settable!
end

--- custom getters, methods
--- FIXME: need explicit tags or something for ldoc
function Poll:__index(idx)
   if idx == 'id' then return self.props.id
   elseif idx == 'name' then return self.props.name
   elseif idx == 'start' then return Poll.start
   elseif idx == 'stop' then return Poll.start
   else
      return rawget(self, idx)
   end      
end


--- Static Methods
-- @section static

--- call with OSC data from norns callback to register all available polls
-- @param data - table from OSC; each entry is { id (int), name (string) }
-- @param coutn - size of table
Poll.register = function(data, count)
   Poll.polls = {}
   Poll.pollNames = {}
   local props
   for i=1,count do
      props = {
	 id = data[i][1]
	 name = data[i][2]
      }
      Poll.pollNames[props.id] = props.name
      Poll.pollNames[props.name] = Poll.new(props)
   end
end

--- get a registered Poll object by name
-- @param name
-- @param callback function to call with value on each poll
Poll.named = function(name, callback)
   local p = Poll.polls[name]
   p.props.callback = callback   
end

--- main handler; called from C
-- @param id - identfier (integer)
-- @param value: value (float OR sequence of bytes)
Poll.handle = function(id, value)
   local p = Poll.polls[Poll.pollNames[id]]
   if p then
      if p.props then
	 if type(p.props.callback) == "function" then
	    p.props.callback(value)
	 end
      end
   end
end

--- Global Functions
-- @section globals
