local monitor = require("component").gpu
local event = require("event")
local thread = require("thread")

function Button()
	local this = {
		top = 1,
		left = 1,
		width = 5,
		height = 5,

		text = "",
		textColor = 0x000000,
		textX = 1,
		textY = 1,
		
		activeColor = 0x008000,
		inactiveColor = 0xFF0000,
		active = true,

		thread = nil,
		call = nil,

		bgColor = 0x000000
	}

	function this.size(width, height)
		this.width = width
		this.height = height
	end

	function this.pos(top, left)
		this.top = top
		this.left = left
	end

	function this.label(text, color)
		this.text = text
		this.textColor = color
	end

	function this.intersect(x, y)
		if x >= this.left and x <= this.left + this.width then
			if y >= this.top and y <= this.top - this.height then
				this.call()
			end
		end
	end

	function this.method(func)
		this.call = func
	end

	function this.show()

		if this.active then
			color = this.activeColor
		else
			color = this.inactiveColor
		end

		monitor.setBackground(color)
		monitor.fill(this.left, this.top, this.width, this.height, " ")

		monitor.setForeground(this.textColor)
		offset = math.floor(string.len(this.text)/2)
		textX = math.floor(this.left + this.width/2) - offset
		textY = math.floor(this.top + this.height/2)
		monitor.set(textX, textY, this.text)
	end

	function this.pause()
		this.thread:suspend()
	end

	function this.hide()
		monitor.setBackground(this.bgColor)
		monitor.fill(this.left, this.top, this.width, this.height, " ")
	end

	function this.stop()
		this.hide()
		this.thread:kill()
	end

	function this.start()
		if this.thread == nil then
			this.thread = thread.create(function()
				while true do
					local _, _, x, y = event.pull(1, touch)
					if x == nil or y == nil then
						local h, w = monitor.getResolution()
						monitor.set(h, w, ".")
						monitor.set(h, w, " ")
					else
						this.intersect(x, y)
					end
				end
			end)
		else
			this.thread:resume()
		end
	end

	return this
end
