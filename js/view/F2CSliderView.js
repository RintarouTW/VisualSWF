F2CSliderView = function() {
	var el = document.createElement("div");
	Object.extend(el, F2CSliderView.prototype);
	el.initialize.apply(el, arguments);
	return el;
}

F2CSliderView.prototype = {

	/* view */
	slider: false,
	
	/* delegate */
	controller:false, /* controller of this view, the delegate */
	
	/* model */
	maxValue: 100.0,
	minValue: 0.0,
	value: 0.0,
	
	/* internal */
	mouseDownX: 0,
	sliderLeftBeforeDrag: 0,
	precision: 1,
	
	initialize : function(controller, minValue, maxValue, defaultValue, precision) {
		this.className = "F2CSliderView";
		this.controller = controller;
		this.maxValue = maxValue;
		this.minValue = minValue;
		this.value = defaultValue;
		this.precision = Math.pow(10, precision);
		this.slider = new E('div', { className : "F2CSliderViewSlider" });
		this.slider.addEventListener('mousedown', this.beginSlide.bind(this), false);
		this.slider.addEventListener('mouseup', this.endSlide.bind(this), false);

		this.appendChild(this.slider);
		this.update(true);
	},
	
	beginSlide: function(event) {
		this.mouseDownX = event.clientX;
		this.sliderLeftBeforeDrag = getValue(this.slider, "left");
		document.onmousemove = this.dragging.bind(this);
		document.onmouseup = this.endSlide.bind(this);
	},
	
	endSlide: function(event) {
		document.onmousemove = null;
	},
	
	dragging: function(event) {
		offsetX = event.clientX - this.mouseDownX;
		myWidth = getValue(this, "width");
		sliderWidth = getValue(this.slider, "width");
		
		newSliderLeft = this.sliderLeftBeforeDrag + offsetX;

		/* range check */
		if (newSliderLeft < 0) {
			newSliderLeft = 0;
		}

		if (newSliderLeft > (myWidth - sliderWidth)) {
			newSliderLeft = (myWidth - sliderWidth);
		}
		
		newValue = this.minValue + (newSliderLeft * (this.maxValue - this.minValue)) / (myWidth - sliderWidth);
		newValue = Math.round(newValue * this.precision) / this.precision;
		this.value = newValue;
		this.update();
	},
	
	/* update view according value */
	update: function(isInit) {
		myWidth = getValue(this, "width");
		sliderWidth = getValue(this.slider, "width");	
		newSliderLeft = (this.value - this.minValue) * (myWidth - sliderWidth) / (this.maxValue - this.minValue);
		this.slider.style.left = newSliderLeft;
		
		if (!isInit && isdefined(this.controller)) {
			this.controller.onSliderChange(this, this.value);
		}
	},

/* Public */
	setValue: function(newValue) {
		this.value = newValue;
		this.update(true);
	}
};