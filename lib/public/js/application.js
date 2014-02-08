$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    
    ws.onmessage = function(msg) {
        //console.log(msg);
        var data = JSON.parse(msg.data);
        console.log(data);
        //$(".trains").append("<p>" + msg.data + "</p>");

        //console.log(trains.length + " " + data.length);
        var trainsdata = data.trains;
        console.log("trains: " + trains.length + " trainsdata: " + trainsdata.length);

        if(trainsdata.length > trains.length){
            while(true){
                //$.extend(true, trains, trainOrigin);
                //trains.push($.extend(true, {}, trainOrigin));
                var tmpTrain = new Sprite(32,32);
                tmpTrain.image = core.assets['./images/chara1.png'];
                tmpTrain.frame = [6,6,7,7];
                trains.push(tmpTrain);
                console.log("in!");
                core.rootScene.addChild([trains[trains.length - 1]]);
                console.log("trains: " + trains.length);
                if(trainsdata.length === trains.length) break;
            }
        } else {
            while(true){
                core.rootScene.removeChild(trains[trains.length - 1]);
                trains.pop();
                if(trainsdata.length === trains.length) break;
            }
        }

        for(i = 0; i < trains.length; ++i){
            trains[i].x = (data.trains[i].x + 1) * 300 + 24;
            trains[i].y = (data.trains[i].y + 1) * 300 + 10;
            if(trains[i].y > 100){
                trains[i].scaleX = -1;
            } else {
                trains[i].scaleX = 1;
            }
        }
    }

    enchant(); // initialize
    var core = new Core(680, 680); // core stage
    core.preload('./images/chara1.png'); // preload image
    core.fps = 20;
    //var bear = new Sprite(32, 32);
    trains = new Array();

    var i;
    /*for(i = 0; i < bear.length; ++i){
        bear[i] = new Sprite(32, 32);   
    }*/

    var trainOrigin = new Sprite(32, 32);

    core.onload = function(){
        trainOrigin.image = core.assets['./images/chara1.png'];
        trainOrigin.frame = [6,6,7,7];
        /*for(i = 0; i < bear.length; ++i){
            bear[i].image = core.assets['./images/chara1.png'];
            core.rootScene.addChild(bear[i]);
            var walkFrame1 = 1 + i % 3 * 5;
            var walkFrame2 = walkFrame1 + 1;
            bear[i].frame = [walkFrame1, walkFrame1, walkFrame2, walkFrame2];   // select sprite frame

            bear[i].x = 100;
            bear[i].y = 100;
        }*/
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

