$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    
    ws.onmessage = function(msg) {
        console.log(msg);
        var data = JSON.parse(msg.data);
        //$(".trains").append("<p>" + msg.data + "</p>");


        for(i = 0; i < bear.length; ++i){
            bear[i].x = (data.trains[i].x + 1) * 100;
            bear[i].y = (data.trains[i].y + 1) * 100;
            if(bear[i].y > 100){
                bear[i].scaleX = -1;
            } else {
                bear[i].scaleX = 1;
            }
        }
    }

    enchant(); // initialize
    var core = new Core(320, 320); // core stage
    core.preload('./images/chara1.png'); // preload image
    core.fps = 20;
    //var bear = new Sprite(32, 32);
    var bear = new Array(10);

    var i;
    for(i = 0; i < bear.length; ++i){
        bear[i] = new Sprite(32, 32);   
    }

    core.onload = function(){
        for(i = 0; i < bear.length; ++i){
            bear[i].image = core.assets['./images/chara1.png'];
            core.rootScene.addChild(bear[i]);
            var walkFrame1 = 1 + i % 3 * 5;
            var walkFrame2 = walkFrame1 + 1;
            bear[i].frame = [walkFrame1, walkFrame1, walkFrame2, walkFrame2];   // select sprite frame

            bear[i].x = 100;
            bear[i].y = 100;
        }
       /* 
        bear.tl.moveBy(288, 0, 90)   // move right
            .scaleTo(-1, 1, 10)      // turn left
            .moveBy(-288, 0, 90)     // move left
            .scaleTo(1, 1, 10)       // turn right
            .loop();                 // loop it
        */
    };

    core.start(); // start your core!`
    $(".subway-map").subwayMap({ debug: true });
});

