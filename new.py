
class Bank:
    balance = 0

    def __init__(self, name, address, gender, occupation):
        self.name = name
        self.address = address
        self.gender = gender
        self.occupation = occupation

    def accbalance(self):
        return self.balance

    def deposit(self, amount):
        self.balance += amount
        print('The amount', amount, 'was successful')

    def withdraw(self, amount):
        self.balance -= amount
        print('The amount', amount, 'was successful and your balance is now', self.balance)


#Child Class
class loan(Bank):
  def __init__(annie, name, address, gender, occupation, citizen):
    super().__init__(name, address, gender, occupation)
    annie.citizen = citizen

  def accbalance(annie):
    return super().accbalance()

  def deposit(annie, amount):
    return super().deposit(amount)

  def withdraw(annie, amount):
    return super().withdraw(amount)

  def eligible(annie, amount):
    value = 1.5 * float(annie.accbalance())
    if int(amount)  <= value:
      print("You are eligible for the loan")
    else:
      print("You are not eligible for the loan")
