class Fixture

   def self.boards(rev=0)
     [{"basecamp_id"=>nil, "budget"=>nil, "completed_at"=>nil, "completed_by_id"=>nil, "cost"=>nil,
        "created_at"=>"Tue, 11 Aug 2009 19:17:06 -0000", "creator_id"=>3, "description"=>"",
        "end_date"=>"Wed, 09 Sep 2009 00:00:00 -0000", "expected_hours_per_day"=>nil,
        "hours"=>43, "is_public"=>false, "level"=>LEVEL_BOARD, "parent_id"=>"12594", "parked"=>false,
        "position"=>nil, "start_date"=>"Mon, 17 Aug 2009 00:00:00 -0000", "status_id"=>6,
        "story_points"=>33, "title"=>"SBX - Sprint 1", "updated_at"=>"2009/11/17 11:59:09 -0500",
        "users"=>[{"id"=>55, "name"=>"Bart Jedrocha"}, {"id"=>3, "name"=>"Brian Kierstead"},
          {"id"=>4, "name"=>"Chelsea Robb"}, {"id"=>128, "name"=>"Chris Foy"},
          {"id"=>43, "name"=>"Cristina Calder"}, {"id"=>1, "name"=>"Dan Frade"},
          {"id"=>10, "name"=>"Justin Hogeterp"}, {"id"=>127, "name"=>"Mike Trpcic"}],
        "stories"=> [
          # story one
          {"basecamp_id"=>nil, "board_id"=>"12594", "budget"=>nil, "completed_at"=>nil,
            "completed_by_id"=>nil, "cost"=>nil, "created_at"=>"Tue, 11 Aug 2009 19:51:09 -0000",
            "creator_id"=>3, "description"=>"Description for Story One\n  ",
            "end_date"=>nil, "expected_hours_per_day"=>nil, "hours"=>17, "id"=>"12595",
            "is_public"=>nil, "level"=>1, "parent_id"=>"12594", "parked"=>false, "position"=>1,
            "start_date"=>nil, "status_id"=>6, "story_points"=>8, "title"=>"Story Two",
            "updated_at"=>"Tue, 17 Nov 2009 16:05:56 -0000",
            "tasks"=>[
              {"basecamp_id"=>nil, "board_id"=>"12594", "budget"=>nil, "completed_at"=>nil,
                "completed_by_id"=>nil, "cost"=>nil, "created_at"=>"Mon, 17 Aug 2009 16:44:56 -0000",
                "creator_id"=>3, "description"=>"Authentication == bail if no session info is found.\n*Learn Rack*",
                "end_date"=>nil, "expected_hours_per_day"=>nil, "hours"=>10, "id"=>"12631", "is_public"=>nil,
                "level"=>2, "parent_id"=>"12595", "parked"=>false, "position"=>1, "start_date"=>nil,
                "status_id"=>4, "story_points"=>nil, "title"=>nil,
                "updated_at"=>"Tue, 18 Aug 2009 14:58:49 -0000",
                "users"=>[
                  {"id"=>3, "name"=>"Brian Kierstead"}
                ]
              }
            ]
          },
          # story two
          {"basecamp_id"=>nil, "board_id"=>"12594", "budget"=>nil, "completed_at"=>nil,
            "completed_by_id"=>nil, "cost"=>nil, "created_at"=>"Tue, 11 Aug 2009 19:51:09 -0000",
            "creator_id"=>3, "description"=>"Description for Story Two\n  ",
            "end_date"=>nil, "expected_hours_per_day"=>nil, "hours"=>17, "id"=>"12596",
            "is_public"=>nil, "level"=>1, "parent_id"=>"12594", "parked"=>false, "position"=>2,
            "start_date"=>nil, "status_id"=>6, "story_points"=>8, "title"=>"Story Two",
            "updated_at"=>"Tue, 17 Nov 2009 16:05:56 -0000",
            "tasks"=>[
              {"basecamp_id"=>nil, "board_id"=>"12594", "budget"=>nil, "completed_at"=>nil,
                "completed_by_id"=>nil, "cost"=>nil, "created_at"=>"Mon, 17 Aug 2009 16:44:56 -0000",
                "creator_id"=>3, "description"=>"Task for story two..\n",
                "end_date"=>nil, "expected_hours_per_day"=>nil, "hours"=>10, "id"=>"12632", "is_public"=>nil,
                "level"=>2, "parent_id"=>"12595", "parked"=>false, "position"=>1, "start_date"=>nil,
                "status_id"=>4, "story_points"=>nil, "title"=>nil,
                "updated_at"=>"Tue, 18 Aug 2009 14:58:49 -0000",
                "users"=>[
                  {"id"=>3, "name"=>"Brian Kierstead"}
                ]
              }
            ]
          }
        ],
        "value"=>{"title"=>"SBX - Sprint 1", "description"=>"", 
          "start_date"=>"Mon, 17 Aug 2009 00:00:00 -0000",
          "end_date"=>"Wed, 09 Sep 2009 00:00:00 -0000",
          "updated_at"=>"2009/11/17 11:59:09 -0500", "level"=>0, "hours" => 43, "story_points" => 33
        },
        "updated_by"=>55, "burndown_image_path"=>nil
     }][rev]
  end
  
  def self.backlogs(rev=0)
    updated_at = 3.hours.ago.strftime("%Y/%m/%d %H:%M:%S %z")
    [{"basecamp_id"=>nil, "budget"=>nil, "completed_at"=>nil, "completed_by_id"=>nil, "cost"=>nil,
        "created_at" => updated_at, "creator_id"=>3, "description"=>"",
        "end_date"=>"Wed, 09 Sep 2009 00:00:00 -0000", "expected_hours_per_day"=>nil,
        "hours"=>43, "is_public"=>false, "level"=>LEVEL_PRODUCT_BACKLOG, "parked"=>false,
        "position"=>nil, "start_date"=>"Mon, 17 Aug 2009 00:00:00 -0000", "status_id"=>6,
        "story_points"=>33, "title"=>"SBX - Sprint 1", "updated_at" => updated_at,
        "users"=>[{"id"=>55, "name"=>"Bart Jedrocha"}, {"id"=>3, "name"=>"Brian Kierstead"},
          {"id"=>4, "name"=>"Chelsea Robb"}, {"id"=>128, "name"=>"Chris Foy"},
          {"id"=>43, "name"=>"Cristina Calder"}, {"id"=>1, "name"=>"Dan Frade"},
          {"id"=>10, "name"=>"Justin Hogeterp"}, {"id"=>127, "name"=>"Mike Trpcic"}],
        "stories"=> [
          {"basecamp_id"=>nil, "board_id"=>"12594", "budget"=>nil, "completed_at"=>nil,
            "completed_by_id"=>nil, "cost"=>nil, "created_at"=> updated_at,
            "creator_id"=>3, "description"=>"Catch-all\n  ",
            "end_date"=>nil, "expected_hours_per_day"=>nil, "hours"=>17, "id"=>"12595",
            "is_public"=>nil, "level"=>1, "parent_id"=>"12594", "parked"=>false, "position"=>1,
            "start_date"=>nil, "status_id"=>6, "story_points"=>8, "title"=>"Directives",
            "updated_at"=>updated_at,
            "tasks"=>[]
           }],
        "updated_by"=>55,
        "twitter" => {"tweet" => false},
        "boards" => []
      }][rev]
  end

  def self.board(rev=0, options={})
    options[:no_stories] ||= false
    options[:no_tasks] ||= false
    options[:no_users] ||= false
    options[:level] ||= LEVEL_BOARD

    result = options[:level] == LEVEL_BOARD ? boards(rev) : backlogs(rev)

    result["stories"] = [] if options[:no_stories]
    result["users"] = [] if options[:no_users]
    result["stories"].each{|story| story["tasks"] = []} if options[:no_tasks]

    return result
  end
end