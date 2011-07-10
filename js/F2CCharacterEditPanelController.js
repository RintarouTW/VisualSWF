/*
 * F2CCharacterEditPanelController
 *
 ****
 * delegate protocol 
 *  - delegate.onCharacterModified(); // Tell delegate the character is modified by this panel controller.
 ****
 */
 
F2CCharacterEditPanelController = Klass(Object, {
	view: false,	/* div */
	
	characterNameLabel: false,
	actorNameLabel: false,
	widthInput: false,
	heightInput: false,
	opacityInput: false,
	anchorXInput: false,
	anchorYInput: false,
	shadowOffsetXInput: false,
	shadowOffsetYInput: false,
	shadowBlurInput: false,
	shadowColorInput: false,
	
	/* delegate protocol 
	   - delegate.onCharacterModified(); // Tell delegate the character is modified by this panel controller.
	 */
	delegate: false,
	
	/* controls */
	opacitySlider: false,       /* F2CSliderView */
	shadowOffsetXSlider: false, /* F2CSliderView */
	shadowOffsetYSlider: false, /* F2CSliderView */
	shadowBlurSlider: false,	/* F2CSliderView */
	
	/* model */
	character: false,		/* currently edited character */
	characterName: "",
	
	initialize: function(delegate) {
		this.delegate = delegate;
		this.view = new E('div', { id : 'F2CCharacterEditPanel' });

		table = new E('table');
		
		tr = new E('tr', "<td>Character Name</td>");

		this.characterNameLabel   = new E('span');
		td = new E('td');
		td.colSpan = 2;
		td.appendChild(this.characterNameLabel);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Played by</td>");
		this.actorNameLabel   = new E('span');
		td = new E('td');
		td.colSpan = 2;		
		td.appendChild(this.actorNameLabel);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Width</td>");
		this.widthInput  = new F2CInputView(this, 0);
		td = new E('td');
		td.colSpan = 2;		
		td.appendChild(this.widthInput);
		tr.appendChild(td);
		table.appendChild(tr);		

		tr = new E('tr', "<td>Height</td>");
		this.heightInput = new F2CInputView(this, 0);
		td = new E('td');
		td.colSpan = 2;		
		td.appendChild(this.heightInput);
		tr.appendChild(td);
		table.appendChild(tr);
		
		tr = new E('tr', "<td>Anchor X</td>");
		this.anchorXInput = new F2CInputView(this, 0);
		this.anchorXInput.style.width = "45px";
		td = new E('td');
		td.appendChild(this.anchorXInput);
		tr.appendChild(td);
		
		td = new E('td');
		this.anchorXOptionSelect = new E('select', {className: "F2COptionSelect"});
		this.anchorXOptionSelect.style.width = "auto";
		option = new E('option', { value : "custom"});
		option.innerHTML = option.value;
		this.anchorXOptionSelect.appendChild(option);
		option = new E('option', { value : "left"});
		option.innerHTML = option.value;
		this.anchorXOptionSelect.appendChild(option);
		option = new E('option', { value : "center"});
		option.innerHTML = option.value;
		this.anchorXOptionSelect.appendChild(option);
		option = new E('option', { value : "right"});
		option.innerHTML = option.value;
		this.anchorXOptionSelect.appendChild(option);
		this.anchorXOptionSelect.onchange = this.onValueChange.bind(this);
		td.appendChild(this.anchorXOptionSelect);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Anchor Y</td>");
		this.anchorYInput = new F2CInputView(this, 0);
		this.anchorYInput.style.width = "45px";
		td = new E('td');
		td.appendChild(this.anchorYInput);
		tr.appendChild(td);
		
		td = new E('td');
		this.anchorYOptionSelect = new E('select', {className: "F2COptionSelect"});
		this.anchorYOptionSelect.style.width = "auto";
		option = new E('option', { value : "custom"});
		option.innerHTML = option.value;
		this.anchorYOptionSelect.appendChild(option);
		option = new E('option', { value : "top"});
		option.innerHTML = option.value;
		this.anchorYOptionSelect.appendChild(option);
		option = new E('option', { value : "middle"});
		option.innerHTML = option.value;
		this.anchorYOptionSelect.appendChild(option);
		option = new E('option', { value : "bottom"});
		option.innerHTML = option.value;
		this.anchorYOptionSelect.appendChild(option);		
		this.anchorYOptionSelect.onchange = this.onValueChange.bind(this);
		td.appendChild(this.anchorYOptionSelect);
		tr.appendChild(td);		
		table.appendChild(tr);

		tr = new E('tr', "<td>Opacity</td>");
		this.opacityInput = new F2CInputView(this, 1);
		td = new E('td');
		td.appendChild(this.opacityInput);
		tr.appendChild(td);

		td = new E('td');
		this.opacitySlider = new F2CSliderView(this, 0.0, 1.0, 0, 2);
		td.appendChild(this.opacitySlider);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Composite Operation</td>");
		td = new E('td');
		td.colSpan = 2;
		this.compositeOptionSelect = new E('select', {className: "F2COptionSelect"});
		option = new E('option', { value : "source-over"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "source-in"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "source-out"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "source-atop"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "destination-over"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "destination-in"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "destination-out"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "destination-atop"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "lighter"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "darker"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "copy"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);
		option = new E('option', { value : "xor"});
		option.innerHTML = option.value;
		this.compositeOptionSelect.appendChild(option);

		td.appendChild(this.compositeOptionSelect);
		tr.appendChild(td);
		table.appendChild(tr);
		
		this.compositeOptionSelect.onchange = this.onValueChange.bind(this);

		tr = new E('tr', "<td>Shadow Offset X</td>");
		this.shadowOffsetXInput = new F2CInputView(this, 0);
		td = new E('td');
		td.appendChild(this.shadowOffsetXInput);
		tr.appendChild(td);
		
		td = new E('td');
		this.shadowOffsetXSlider = new F2CSliderView(this, -50, 50, 0, 0);
		td.appendChild(this.shadowOffsetXSlider);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Shadow Offset Y</td>");
		this.shadowOffsetYInput = new F2CInputView(this, 0);
		td = new E('td');
		td.appendChild(this.shadowOffsetYInput);
		tr.appendChild(td);

		td = new E('td');
		this.shadowOffsetYSlider = new F2CSliderView(this, -50, 50, 0, 0);
		td.appendChild(this.shadowOffsetYSlider);
		tr.appendChild(td);

		table.appendChild(tr);

		tr = new E('tr', "<td>Shadow Blur</td>");
		this.shadowBlurInput = new F2CInputView(this, 0);
		td = new E('td');
		td.appendChild(this.shadowBlurInput);
		tr.appendChild(td);

		td = new E('td');
		this.shadowBlurSlider = new F2CSliderView(this, 0, 100, 0, 1);
		td.appendChild(this.shadowBlurSlider);
		tr.appendChild(td);

		table.appendChild(tr);

		tr = new E('tr', "<td>Shadow Color</td>");

		td = new E('td');
		this.shadowColorRect = new E('div', { className:'F2CColorRect' });

		td.appendChild(this.shadowColorRect);
		tr.appendChild(td);

		this.shadowColorInput = new E('input', { className:'F2CColorInput', value : "#000000" });
		this.shadowColorInput.addEventListener("change", this.onColorChange.bind(this), false);
		
		td = new E('td');
		td.appendChild(this.shadowColorInput);
		tr.appendChild(td);

		table.appendChild(tr);
		
		this.view.appendChild(table);
		document.body.appendChild(this.view);

		/* manual binding for jscolor picker */
		colorPicker = new jscolor.color(this.shadowColorInput, { 
				hash:true, 
				pickerPosition: "right",
				pickerFaceColor: "#353637",
				pickerBorderColor: "#454647",
				pickerInsetColor: "#454647",
				styleElement : this.shadowColorRect
			});
		this.shadowColorInput.color = colorPicker
		this.shadowColorRect.addEventListener("click", colorPicker.showPicker.bind(colorPicker), false);
	},
	
	/* action for jscolor */
	onColorChange: function() {
		this.character.shadowColor = this.shadowColorInput.value;
		this.update();
		this.notifyDelegate();
	},
	
	/* action for F2CSliderView(s) */
	onSliderChange: function(sliderView, newValue) {
		switch(sliderView) {
			case this.shadowOffsetXSlider:
				this.character.shadowOffsetX = newValue;
			break;
			case this.shadowOffsetYSlider:
				this.character.shadowOffsetY = newValue;
			break;
			case this.shadowBlurSlider:
				this.character.shadowBlur = newValue;
			break;
			case this.opacitySlider:
				this.character.opacity = newValue;
			break;
		}
		this.update();
		this.notifyDelegate();
	},
	
	notifyDelegate: function() {
		this.delegate.onCharacterModified(this);
	},
	
	/* action for F2CInputView(s) = input.onchange event */
	onValueChange: function(event) {
	    sender = event.target;  // input element	    
	    switch (sender) {
	        case this.widthInput:
	            value = parseInt(sender.value);
	            this.character.width = value;
	        break;
	        case this.heightInput:
    	        value = parseInt(sender.value);
	            this.character.height = value;
	        break;
	        case this.opacityInput:
	        	value = parseFloat(sender.value);
	            this.character.opacity = value;
	        break;
	        case this.anchorXInput:
	            value = parseInt(sender.value);
	            this.character.anchorX = value;
	        break;
	        case this.anchorYInput:
	            value = parseInt(sender.value);
	            this.character.anchorY = value;
	        break;
	        case this.shadowOffsetXInput:
	            value = parseInt(sender.value);
	            this.character.shadowOffsetX = value;
	        break;
	        case this.shadowOffsetYInput:
	            value = parseInt(sender.value);
	            this.character.shadowOffsetY = value;
	        break;
	        case this.shadowBlurInput:
	            value = parseFloat(sender.value);
	            this.character.shadowBlur = value;
	        break;
	        case this.compositeOptionSelect:
	            this.character.compositeOperation = this.compositeOptionSelect.value;
	        break;
	        case this.anchorXOptionSelect:
	            if (this.anchorXOptionSelect.value == "custom") {
	                this.character.anchorX = this.delegate.anchorPoint.x;
	            } else {
	                this.character.anchorX = this.anchorXOptionSelect.value;
	            }
	        break;
	        case this.anchorYOptionSelect:
	            if (this.anchorYOptionSelect.value == "custom") {
	                this.character.anchorY = this.delegate.anchorPoint.y;
	            } else {
	                this.character.anchorY = this.anchorYOptionSelect.value;
	            }
	        break;
	    }
	    this.update();
	    this.notifyDelegate();
	},

	/* update the views to fit the data model */
	update: function() {
		if(!this.character) 
			return;
		this.characterNameLabel.innerHTML = this.characterName;
		this.actorNameLabel.innerHTML = this.character.actorName;
		this.widthInput.value = this.character.width;
		this.heightInput.value = this.character.height;
		this.anchorXInput.value = this.character.anchorX;
		this.anchorYInput.value = this.character.anchorY;
		this.opacityInput.value = this.character.opacity;
		this.shadowOffsetXInput.value = this.character.shadowOffsetX;
		this.shadowOffsetYInput.value = this.character.shadowOffsetY;
		this.shadowBlurInput.value = this.character.shadowBlur;
		this.shadowColorInput.value = this.character.shadowColor;
		this.shadowColorRect.style.backgroundColor = this.character.shadowColor;
		this.compositeOptionSelect.value = this.character.compositeOperation;
		if (typeof(this.character.anchorX) == "number") {
		    if (this.anchorXOptionSelect.value != "custom")
        		this.anchorXOptionSelect.value = "custom";
		} else {		
		    this.anchorXOptionSelect.value = this.character.anchorX;
		}
		if (typeof(this.character.anchorY) == "number") {
		    if (this.anchorYOptionSelect.value != "custom")		
        		this.anchorYOptionSelect.value = "custom";
		} else {
		    this.anchorYOptionSelect.value = this.character.anchorY;
		}
	},

/* Public */
	setCharacter: function(charName, theCharacter) {
		if (isdefined(charName) & isdefined(theCharacter)) {
			this.characterName = charName;
			this.character = theCharacter;
			this.update();
			this.shadowOffsetXSlider.setValue(this.character.shadowOffsetX);
			this.shadowOffsetYSlider.setValue(this.character.shadowOffsetY);
			this.shadowBlurSlider.setValue(this.character.shadowBlur);
			this.opacitySlider.setValue(this.character.opacity);
		}
	},
	
	setVisible: function(visible) {
		if(visible) {
			setVisibility(this.view, true);
		} else {
			setVisibility(this.view, false);
		}
	}	
});
