Parse.Cloud.afterSave("SpotlightMedia",
                      function(request) {
                      request.object.
                      fetch({
                            success: function(media){
                            console.log("made it here1!");
                            var teamQuery = media.get("parent").
                            fetch({
                                  success: function(spotlight) {
                                  console.log("made it here2!");
//                                  spotlight.get("team").
//                                  fetch({
//                                        success: function(teams) {
//                                        console.log("made it here3!");
//                                        var query = new Parse.Query("User");
//                                        query.containedIn("teams", teams);
//                                        query.find({
//                                                   success:function(users){
//                                                   console.log("made it here4!");
//                                                   }
//                                        });
//                                        }
//                                        });
//                                  
//                                  
                                  
                                  }
                                  
                                  });
                            
                            }
                            });
                      });

//                      query.find({
//                                 success: function(firstResults) {
//                                 var teamQuery = parent("team").query();
//                                 teamQuery.find({
//                                                success: function(secondResults) {
//                                                console.log("made it here!");
//
//                                                var userQuery = secondResults("teamParticipants");
//                                                //                    userQuery.find({
//                                                //                       success: function(thirdResults) {
//                                                
//                                                var pushQuery = new Parse.Query(Parse.Installation);
//                                                pushQuery.equalTo('deviceType', 'ios'); // targeting iOS devices only
//                                                pushQuery.containedIn('user', thirdResults);
//                                                Parse.Push.send({
//                                                                where: pushQuery, // Set our Installation query
//                                                                data: {
//                                                                alert: "Message: "
//                                                                }
//                                                                }).then(function() {
//                                                                        // Push was successful
//                                                                        }, function(error) {
//                                                                        throw "Got an error " + error.code + " : " + error.message;
//                                                                        });
//                                                //                       },
//                                                //                       error: function(err) { 
//                                                //                           response.error(err);
//                                                //                       }
//                                                //                    });
//                                                },
//                                                error: function(err) {
//                                                console.log("errrrrrrrror");
//                                                response.error(err);
//                                                }
//                                                });
//                                 },
//                                 error: function(err) { 
//                                 response.error(err);
//                                 }
//                                 });
//                      });
