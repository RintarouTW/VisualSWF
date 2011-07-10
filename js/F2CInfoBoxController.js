/* F2C Info Box */

F2CInfoBoxController = Klass(Object, {
    /* view */
    view: false,     /* Element, also the container. */

	actorNameLabel: false,
	actorWidthLabel: false,
	actorHeightLabel: false,
	
	initialize: function() {
		this.view = new E('div', { id : 'InfoBox' });

		table = new E('table');
		
		tr = new E('tr', "<td>Actor Name</td>");
		this.actorNameLabel   = new E('span');
		td = new E('td');
		td.appendChild(this.actorNameLabel);
		tr.appendChild(td);
		table.appendChild(tr);

		tr = new E('tr', "<td>Width</td>");
		this.actorWidthLabel  = new E('span', "0");
		td = new E('td');
		td.appendChild(this.actorWidthLabel);
		tr.appendChild(td);
		table.appendChild(tr);
		
		tr = new E('tr', "<td>Height</td>");
		this.actorHeightLabel = new E('span', "0");
		td = new E('td');
		td.appendChild(this.actorHeightLabel);
		tr.appendChild(td);
		table.appendChild(tr);		
		
		this.view.appendChild(table);
	},

/* public */

	setViewTop: function(newTop) {
		this.view.style.top = newTop + "px";
	},

	setVisible: function(visible) {
		if(visible) {
			setVisibility(this.view, true);
		} else {
			setVisibility(this.view, false);
		}
	},
	
	update: function(actorName, width, height) {
		this.actorNameLabel.innerHTML   = actorName;
		this.actorWidthLabel.innerHTML  = width;
		this.actorHeightLabel.innerHTML = height;		
	}
});