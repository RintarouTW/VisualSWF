/* F2C Character & Controller */

/* Data Model */

function F2CCharacterCreate(actorName, charWidth, charHeight) {
    newChar = { /* F2CCharacter */
        actorName: actorName,
        width: charWidth,       /* in pixels */
        height: charHeight,     /* in pixels */
        anchorX: 0,             /* in actor's coordinate */
        anchorY: 0,             /* in actor's coordinate */
        shadowOffsetX: 0,
        shadowOffsetY: 0,
        shadowBlur: 0,
        shadowColor: "#000000",
        opacity: 1.0,
        compositeOperation: "source-over"
    };
    return newChar;
}

/* Controller */
F2CCharacterController = Klass(Object, {
    /* view */
    view: false,        /* F2CTableItemView */
        
    isEditing: false,   /* true if is editing by the editor controller */
    
    /* model */    
    name: "",           /* Name of the character, back reference to the scene*/
    dataModel: false,
    character: false,   /* alias of dataModel */
    
    initialize : function(theCharacterName, theCharacter) {
        this.name       = theCharacterName;
        this.dataModel  = theCharacter;
        this.character  = this.dataModel;

        /* TODO */
        actorName = theCharacter.actorName;
        actorController = castController.getActorControllerByName(actorName); /* TODO, castController is global so far...*/
        iconDrawer = actorController.getActor();
        /* init view */
       this.view = new F2CTableItemView(this, this.name, iconDrawer);
    },
    
    getActorName: function() {
        return this.character.actorName;
    },
    
    /* change character.actorName to the new Name */
    setActorName: function(newName) {
        this.character['actorName'] = newName;
        this.updateView();
    },

    setName: function(newName) {
        this.name = newName;
        this.updateView();
    },

    setEditing: function(isEditing) {
        this.isEditing = isEditing;
        this.updateView();
    },

    updateView: function() {
        actorName = this.dataModel.actorName;
        actorController = castController.getActorControllerByName(actorName); /* TODO, castController is global so far...*/
        iconDrawer = actorController.getActor();
        this.view.setName(this.name);
        this.view.update(iconDrawer);
        if (this.isEditing) {
            this.view.nameLabel.style.color = "#dcff00";
        } else {
            this.view.nameLabel.style.color = "#ffffff";
        }
    },

    scrollIntoView: function() {
        this.view.scrollToView();
    },

    remove: function() {
        // remove the view from it's parent
        this.view.remove();
    },

    toJSON : function() {
        var str = "";
        for (pName in this.dataModel) {
            if (str)
                str += ",\n";
            if (typeof (this.dataModel[pName]) == "string") {
                str += "    " + pName + " : \"" + this.dataModel[pName] + "\"";
            } else {
                str += "    " + pName + " : " + this.dataModel[pName];
            }
        }
        return str;
    }    
});
