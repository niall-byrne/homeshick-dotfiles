#!/usr/bin/python

import datetime
import schedule

MARATHON = datetime.datetime(2020, 10, 18, 9, 00, 00, 00)
NOW = datetime.datetime.now()


def get_weeks():
    marathon_week = int(MARATHON.strftime("%W"))
    current_week = int(NOW.strftime("%W"))
    if current_week > marathon_week:
        return marathon_week, 0
    return marathon_week, 16 - (marathon_week - current_week)


def miles_to_km(miles):
    return float(miles) * 1.60934


def overview(target_week, current_week):
    if 0 < target_week < 17:
        if target_week == 1:
            target_name = "First Week"
        elif target_week == current_week + 1:
            target_name = "Next Week"
        elif target_week == current_week:
            target_name = "This Week"
        else:
            target_name = "Week %s" % target_week

        if target_week in schedule.data_set:
            data = dict(schedule.data_set[target_week])
            for key, value in data.items():
                if key != 'runs':
                    data[key] = miles_to_km(value)
            print(target_name +
                  "'s Long Run: {long:.2f} km, Total Distance: {week:.2f} km "
                  "over {runs} runs total.".format(**data))


def main():
    training_start = MARATHON - datetime.timedelta(weeks=16)
    marathon_week, current_week = get_weeks()

    print("Official Training Start Date: %s" %
          training_start.strftime('%Y-%m-%d'))
    print("Days Until Marathon: %s" % (MARATHON - NOW).days)

    print("\nTHIS IS TRAINING WEEK: %s" % current_week)
    overview(current_week + 0, current_week)
    overview(current_week + 1, current_week)


if __name__ == '__main__':
    main()
