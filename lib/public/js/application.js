$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    
    ws.onmessage = function(msg) {
        console.log(msg);
        var data = JSON.parse(msg.data);
        //$(".trains").append("<p>" + msg.data + "</p>");

        bear.x = (data.trains[0].x + 1) * 100;
        bear.y = (data.trains[0].y + 1) * 100;
        if(bear.y > 100){
            bear.scaleX = -1;
        } else {
            bear.scaleX = 1;
        }
    }

    enchant(); // initialize
    var core = new Core(320, 320); // core stage
    core.preload('./images/chara1.png'); // preload image
    core.fps = 20;
    var bear = new Sprite(32, 32);

    core.onload = function(){
        bear.image = core.assets['./images/chara1.png'];
        core.rootScene.addChild(bear);
        bear.frame = [6, 6, 7, 7];   // select sprite frame

        bear.x = 100;
        bear.y = 100;
       /* 
        bear.tl.moveBy(288, 0, 90)   // move right
            .scaleTo(-1, 1, 10)      // turn left
            .moveBy(-288, 0, 90)     // move left
            .scaleTo(1, 1, 10)       // turn right
            .loop();                 // loop it
        */
    };

    core.start(); // start your core!`
});

