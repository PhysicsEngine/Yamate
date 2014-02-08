$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    msgflag = false;

    //pre trains sprite objects
    var preTrains = [];

    ws.onmessage = function(msg) {
        var data = JSON.parse(msg.data);
        if(!data.trains){return;}
        if(msgflag) {console.log(data)}
        //$(".trains").append("<p>" + msg.data + "</p>");
        var trains = data.trains;

        for(var i=0;i<preTrains.length;i++){
            core.rootScene.removeChild(preTrains[i]);
        }
        preTrains = [];
        for(i = 0; i < trains.length; ++i){
            var train = new Train();
            train.x = (trains[i].x + 1) * 300 + 24;
            train.y = (trains[i].y + 1) * 300 + 10;
            if(train.y>100){
                train.scaleX = -1;
            }else{
                train.scaleX = -1;
            }
            preTrains.push(train);
            core.rootScene.addChild(train);
        }
    }

    enchant(); // initialize
    var core = new Core(680, 680); // core stage
    core.preload('./images/chara1.png'); // preload image
    core.fps = 20;

    core.onload = function(){
       /* 
        bear.tl.moveBy(288, 0, 90)   // move right
            .scaleTo(-1, 1, 10)      // turn left
            .moveBy(-288, 0, 90)     // move left
            .scaleTo(1, 1, 10)       // turn right
            .loop();                 // loop it
        */
    };

    // Train Object Class
    var Train = Class.create(Sprite, {
        // 初期化
        initialize: function() {
            Sprite.call(this, 32, 32);
            this.image = core.assets['./images/chara1.png'];
            var walkFrame1 = 1 + 0 % 3 * 5;
            var walkFrame2 = walkFrame1 + 1;
            this.frame = [walkFrame1, walkFrame1, walkFrame2, walkFrame2];   // select sprite frame
        }
    });

    core.start(); // start your core!`
    $(".subway-map").subwayMap({ debug: true });
});

