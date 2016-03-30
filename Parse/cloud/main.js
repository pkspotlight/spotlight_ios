Parse.Cloud.
afterSave("SpotlightMedia",
          function(request) {
          request.object.
          fetch({
                success: function(media){
                console.log(JSON.stringify(media));
                media.get("parent").
                fetch({
                      success: function(spotlight) {
                      console.log(JSON.stringify(spotlight));
                      spotlight.get("team").
                      fetch({
                            success: function(team) {
                            console.log(JSON.stringify(team));
                            var userQuery = new Parse.Query(Parse.User);
                            userQuery.equalTo("teams", team);
                            
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.matchesQuery("owner", userQuery);
                            var msg = "There is new media in a Spotlight from ";
                            Parse.Push.
                            send({
                                 where: pushQuery, 
                                 data: {
                                    alert: msg.concat(team.get("teamName"))
                                 }
                                 }).
                            then(function() {
                                 console.log("Should have worked");
                                 }, function(error) {
                                 throw "Got an error " + error.code + " : " + error.message;
                                 });
                            //});
                            }
                            //                                        ,
                            //                                        error: function(err) {
                            //                                            console.log(JSON.stringify(err));
                            //                                        //                                                response.error(err);
                            //                                        }
                            
                            });
                      
                      }
                      });
                
                }
                });
          });