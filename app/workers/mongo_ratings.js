var MAX_BLOCK    = 100000;
var BLOCK_CHANGE = 10;
var MAX_CHANGES  = 3;
var BULK_BOUND   = 3000;

var calcRating = function(coll, ratingField, placeField, defaultQuery) {

  var withDefault = function(query) {
    if (defaultQuery == undefined) return query;
    var result = query;
    for (var i in defaultQuery)
      result[i] = defaultQuery[i];
    return result;
  }

  var createPlan = function(upper, lower, block, change) {

    var up = upper;
    var result = [];

    while (up > lower) {
      var down = up - block;
      if (down < lower) down = lower;

      var query = {};
      query[ratingField] = { $gte: down, $lte: up };
      var count = coll.find(withDefault(query)).count();

      if (count > BULK_BOUND) {
        if (change > 0) {
          result = result.concat(createPlan(up, down, block / BLOCK_CHANGE, change - 1));
        } else {
          result.push({
            type: 'bulk',
            lower: down,
            upper: up,
            count: count
          });
        }
      } else if (count > 0) {
        result.push({
          type: 'foreach',
          lower: down,
          upper: up,
          count: count
        });
      }

      up -= block;
    }

    return result;
  };

  var planInfo = function(plan) {
    var foreachs = 0, bulks = 0;
    for (var i in plan) {
      var checkpoint = plan[i];
      if (checkpoint.type == 'foreach')
        foreachs += checkpoint.count;
      else
        bulks += (checkpoint.upper - checkpoint.lower) + 1;
    }
    print("Foreachs: " + foreachs);
    print("Bulks: " + bulks);
  };

  var executePlan = function(plan) {
    var place = 0;
    var lastRating = null;

    for (var i in plan) {
      var step = plan[i];
      print("Executing from " + place + ":");
      printjson(step);

      if (step.type == 'foreach') {

        var query = { $query: {}, $orderby: {} };
        query['$query'][ratingField] = { $gte: step.lower, $lte: step.upper };
        query['$query'] = withDefault(query['$query']);
        query['$orderby'][ratingField] = -1;

        coll.find(query).forEach(function(user) {
          if (user.rating != lastRating) {
            lastRating = user.rating;
            place += 1;
          }
          user[placeField] = place;
          coll.save(user);
        });

      } else if (step.type == 'bulk') {

        lastRating = null;
        for (var r = step.upper; r >= step.lower; --r) {
          var findQuery = {}; findQuery[ratingField] = r;
          if (coll.find(withDefault(findQuery)).count() > 0) {
            place += 1;
            var setQuery = { $set: {} }; setQuery['$set'][placeField] = place;
            coll.update(findQuery, setQuery, { multi: true });
          }
        }

      }
    }
  };

  var ratingQuery = { $query: withDefault({}), $orderby: {} };
  ratingQuery['$orderby'][ratingField] = -1;
  var result = coll.findOne(ratingQuery);

  if (result != undefined) {
    var maxRating = result[ratingField];
    ratingQuery['$orderby'][ratingField] = 1;
    var minRating = coll.findOne(ratingQuery)[ratingField];
    if (maxRating == undefined) maxRating = 0;
    if (minRating == undefined) minRating = 0;

    var plan = createPlan(maxRating, minRating, MAX_BLOCK, MAX_CHANGES);
    planInfo(plan);
    executePlan(plan);
  } else {
    print("No data! Skip.");
  }
};


var date = new Date(), stamp;

print(" - - - ");
print("Run at: " + date.toString());

print("Global rating");
calcRating(db.users, 'rating', 'place');
print("Goals rating");
calcRating(db.users, 'goals', 'goals_place');
print("Passes rating");
calcRating(db.users, 'goal_passes', 'passes_place');

print("Monthly rating");
stamp = date.getFullYear() * 100 + (date.getMonth() + 1)
calcRating(db.users, 'monthly_rating', 'monthly_place', { monthly_rating_month: stamp });
db.users.update({ monthly_rating_month: { $ne: stamp } }, { $set: { monthly_place: 0 } }, { multi: true });

print("Daily rating");
stamp = date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();
calcRating(db.users, 'daily_rating', 'daily_place', { daily_rating_day: stamp });
db.users.update({ daily_rating_day: { $ne: stamp } }, { $set: { daily_place: 0 } }, { multi: true });

print("Done!");
