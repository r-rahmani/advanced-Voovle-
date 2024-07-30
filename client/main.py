from termcolor import colored
from tabulate import tabulate
import psycopg2

con = psycopg2.connect(database="voovle", user="postgres", password="", host="127.0.0.1", port="5432")
cur = con.cursor()


def print_error(err):
    err = str(err)
    index = err.find('\n')
    print(colored(err[: index], 'red'))


state = 1
back_state = 0
logged_in_username = ''
page_number = 1
page_size = 5
selected_email = 0

while True:
    if state == 1:  # welcome menu
        print('Welcome to Voovle!')
        print('1. Sign up')
        print('2. Login')
        print('Please select a command:', end=' ')
        command = input()

        if command == '1':
            state = 2
        elif command == '2':
            state = 3

    elif state == 2:  # sign up
        print('Please enter the following information:')
        username = input('Username: ')
        password = input('Password: ')
        account_phone_number = input('Account Phone Number: ')
        address = input('Address: ')
        first_name = input('First Name: ')
        last_name = input('Last Name: ')
        birth_date = input('Birth Date (yyyy-mm-dd): ')
        nick_name = input('Nickname: ')
        national_id = input('National ID: ')
        accessed_by_default = input('Should other users have access to your account? (y/n): ')
        accessed_by_default = True if accessed_by_default == 'y' else False

        try:
            cur.execute('select * from sign_up(\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\','
                        '\'%s\', \'%s\', \'%s\', \'%s\')'
                        % (username, password, account_phone_number, address, first_name,
                            last_name, birth_date, nick_name, national_id, accessed_by_default))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 1

        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 1

    elif state == 3:  # login
        print('Please enter the following information:')
        email = input('Email Address: ')
        password = input('Password: ')

        try:
            cur.execute('select * from login(\'%s\', \'%s\')' % (email, password))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 1
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            logged_in_username = email[:len(email) - 11]
            state = 4

    elif state == 4:  # user menu
        print('Welcome %s!' % logged_in_username)
        print('1. Show Notifications')
        print('2. Send Email')
        print('3. Inbox')
        print('4. Sent')
        print('5. Search User')
        print('6. Account')
        print('7. Permissions')
        print('8. Log Out')
        print('Please select a command:', end=' ')

        command = input()
        if command == '1':
            state = 5
        elif command == '2':
            state = 10
        elif command == '3':
            page_number = 1
            state = 6
        elif command == '4':
            page_number = 1
            state = 9
        elif command == '5':
            state = 11
        elif command == '6':
            state = 12
        elif command == '7':
            state = 15
        elif command == '8':
            logged_in_username = ''
            state = 1

    elif state == 5:  # notifications
        try:
            cur.execute('select * from get_notifications()')
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print(tabulate(rows, cols, tablefmt='psql'))
            input('Press enter to go back.')

            state = 4

    elif state == 6:  # inbox

        try:
            cur.execute('select * from get_inbox(%d, %d)' % (page_number, page_size))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print('Inbox:')
            print(tabulate(rows, cols, tablefmt='psql'))
            print('Page %d' % page_number)

            print()
            print('1. Show Email')
            print('2. Next Page')
            print('3. Previous Page')
            print('4. Back')
            print('Please select a command:', end=' ')

            command = input()
            if command == '1':
                selected_email = int(input('Please enter email ID: '))
                back_state = 6
                state = 7
            elif command == '2':
                page_number += 1
            elif command == '3' and page_number != 1:
                page_number -= 1
            elif command == '4':
                state = 4

    elif state == 7:  # show email
        try:
            cur.execute('select * from get_email(%d)' % selected_email)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 6
        else:
            con.commit()
            rows = cur.fetchall()

            email = rows[0]
            print('Time Sent: %s' % str(email[6]))
            print('From: %s' % email[1])
            print('To: %s' % email[2])
            if email[3] is not None:
                print('CC: %s' % email[3])
            print('Subject: %s' % email[4])
            print('Message:')
            print(email[5])

            print()
            print('1. Delete Email')
            print('2. Back')
            print('Please select a command:', end=' ')

            command = input()
            if command == '1':
                state = 8
            elif command == '2':
                state = back_state

    elif state == 8:  # delete email
        try:
            cur.execute('select * from delete_email(%d)' % selected_email)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 7
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = back_state

    elif state == 9:  # sent

        try:
            cur.execute('select * from get_sent_emails(%d, %d)' % (page_number, page_size))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print('Sent:')
            print(tabulate(rows, cols, tablefmt='psql'))
            print('Page %d' % page_number)

            print()
            print('1. Show Email')
            print('2. Next Page')
            print('3. Previous Page')
            print('4. Back')
            print('Please select a command:', end=' ')

            command = input()
            if command == '1':
                selected_email = int(input('Please enter email ID: '))
                back_state = 9
                state = 7
            elif command == '2':
                page_number += 1
            elif command == '3' and page_number != 1:
                page_number -= 1
            elif command == '4':
                state = 4

    elif state == 10:  # send email

        print('Please enter the following information:')
        print('Write \'cc:\' in the beginning if you want to cc an email address (cc:example@voovle.com)')
        all_recipients = []
        while True:
            print('Recipient / CC: (enter x to finish): ', end='')
            inp = input()
            if inp == 'x':
                break
            else:
                all_recipients.append(inp)

        subject = input('Subject: ')
        print('Message:')
        message = input()

        try:
            query = 'select * from send_email(\'%s\', \'%s\'' % (subject, message)
            for r in all_recipients:
                query = '%s, \'%s\'' % (query, r)
            query = '%s%s' % (query, ')')

            cur.execute(query)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 4

    elif state == 11:  # search user
        target_email_address = input('Enter user\'s email address: ')

        try:
            cur.execute('select * from get_personal_data(\'%s\')' % target_email_address)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            con.commit()
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print()
            print('Result:')
            print(tabulate(rows, cols, tablefmt='psql'))

            state = 4

    elif state == 12:  # get account information
        try:
            cur.execute('select * from get_own_account_data()')
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 4
        else:
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print()
            print('Account:')
            print(tabulate(rows, cols, tablefmt='psql'))

            print()
            print('1. Edit Account information')
            print('2. Change Password')
            print('3. Delete Account')
            print('4. Back')
            print('Please select a command:', end=' ')

            command = input()
            if command == '1':
                state = 14
            elif command == '2':
                state = 13
            elif command == '3':
                state = 19
            elif command == '4':
                state = 4

    elif state == 13:  # change password
        old_password = input('Old Password: ')
        new_password = input('New Password: ')

        try:
            cur.execute('select * from update_password(\'%s\', \'%s\')' % (old_password, new_password))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 12
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 12

    elif state == 14:  # edit account information
        print('Please enter the following information: (Just press enter if you don\'t want to update a field)')
        account_phone_number = input('Account Phone Number: ') or 'null'
        address = input('Address: ') or 'null'
        first_name = input('First Name: ') or 'null'
        last_name = input('Last Name: ') or 'null'
        phone_number = input('Phone Number: ') or 'null'
        birth_date = input('Birth Date (yyyy-mm-dd): ') or 'null'
        nick_name = input('Nickname: ') or 'null'
        national_id = input('National ID: ') or 'null'

        try:
            cur.execute('select * from update_account_data(\'%s\', \'%s\', \'%s\', \'%s\','
                        '\'%s\', \'%s\', \'%s\', \'%s\')'
                        % (account_phone_number, address, first_name, last_name,
                           phone_number, birth_date, nick_name, national_id))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 12
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 12

    elif state == 15:  # permissions
        try:
            cur.execute('select * from get_default_access()')
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 12
        else:
            accessed_by_default = cur.fetchall()[0][0]
            print('Default Permission: Allowed' if accessed_by_default else 'Default Permission: Denied')

        try:
            cur.execute('select * from get_permission_overrides()')
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 12
        else:
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]

            print('Overrides:')
            print(tabulate(rows, cols, tablefmt='psql'))

        print()
        print('1. Set Default Permission')
        print('2. Add Override')
        print('3. Delete Override')
        print('4. Back')
        print('Please select a command:', end=' ')

        command = input()
        if command == '1':
            state = 16
        elif command == '2':
            state = 17
        elif command == '3':
            state = 18
        elif command == '4':
            state = 4

    elif state == 16:  # set default permission
        inp = input('Should other users be able to see your account information by default? (y/n): ')
        accessed_by_default = True if inp == 'y' else False

        try:
            cur.execute('select * from set_default_access(%s)' % accessed_by_default)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 15
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 15

    elif state == 17:  # add permission override
        target_email_address = input('User\'s Email Address: ')
        inp = input('Should the user be able to see your account information? (y/n): ')
        accessed = True if inp == 'y' else False

        try:
            cur.execute('select * from add_permission_override(\'%s\', \'%s\')' % (target_email_address, accessed))
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 15
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 15

    elif state == 18:  # delete permission override
        target_email_address = input('User\'s Email Address: ')

        try:
            cur.execute('select * from delete_permission_override(\'%s\')' % target_email_address)
        except Exception as err:
            print_error(err)
            con.rollback()
            state = 15
        else:
            con.commit()
            print(colored(cur.fetchall()[0][0], 'green'))
            state = 15

    elif state == 19:  # delete account
        inp = input('Are you sure? (y/n)')
        if inp == 'y':
            try:
                cur.execute('select * from delete_account()')
            except Exception as err:
                print_error(err)
                con.rollback()
                state = 12
            else:
                con.commit()
                print(colored(cur.fetchall()[0][0], 'green'))
                state = 1
        else:
            state = 12

    print()
    print()