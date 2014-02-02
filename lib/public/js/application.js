$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    
    ws.onmessage = function(msg) {
        console.log(msg);
        var data = JSON.parse(msg.data);
        $(".trains").append("<p>" + msg.data + "</p>");
    }
    /*
    enchant();
    var game = new Core(320,320); // create a new game with resolution of 320x320
    game.preload('start.png'); // specifies which image files should be loaded when the game starts
    game.onload = function(){ // describes what should be executed when the game starts
        var bear = new Sprite(32,32); // create a sprite
        bear.image = game.assets['start.png']; // specifies the image file *this must have been preloaded
        bear.x = 50; // specifies position on the x-axis
        bear.y = 50; // specifies position on the y-axis
        game.rootScene.addChild(bear); // display the image on the screen
    }
    game.start(); // begin the game
    */
});

