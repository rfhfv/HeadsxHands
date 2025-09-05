import Cocoa

// Базовый класс для всех существ
class Creature {
    let attack: Int
    let defense: Int
    var health: Int
    let maxHealth: Int
    let damageRange: DamageRange
    
    init(attack: Int, defense: Int, maxHealth: Int, damageRange: DamageRange) {
        guard attack >= 1 && attack <= 30 else { fatalError("Атака должна быть от 1 до 30") }
        guard defense >= 1 && defense <= 30 else { fatalError("Защита должна быть от 1 до 30") }
        guard maxHealth > 0 else { fatalError("Здоровье должно быть положительным") }
        
        self.attack = attack
        self.defense = defense
        self.maxHealth = maxHealth
        self.health = maxHealth
        self.damageRange = damageRange
    }
    
    func isDead() -> Bool {
        return health <= 0
    }
    
    func takeDamage(amount: Int) {
        health = max(0, health - amount)
    }
    
    func attack(target: Creature) {
        let modifier = max(1, attack - target.defense + 1)
        let dice = Dice()
        
        if dice.roll(count: modifier).contains(where: { $0 >= 5 }) {
            let damage = damageRange.randomDamage()
            target.takeDamage(amount: damage)
            print("Успешный удар! Нанесенный урон: \(damage)")
        } else {
            print("Нападающий промахнулся!")
        }
    }
}

// Класс игрока
class Player: Creature {
    private(set) var healCount = 4
    
    override init(attack: Int, defense: Int, maxHealth: Int, damageRange: DamageRange) {
        super.init(attack: attack, defense: defense, maxHealth: maxHealth, damageRange: damageRange)
    }
    
    func heal() {
        guard healCount > 0 else {
            print("Исцеление недоступно!")
            return
        }
        
        let healAmount = Int(Double(maxHealth) * 0.3)
        health = min(maxHealth, health + healAmount)
        healCount -= 1
        print("Исцеленное кол-во здоровья: \(healAmount). Осталось использований: \(healCount)")
    }
}

// Класс монстра
class Monster: Creature {
    override init(attack: Int, defense: Int, maxHealth: Int, damageRange: DamageRange) {
        super.init(attack: attack, defense: defense, maxHealth: maxHealth, damageRange: damageRange)
    }
}

// Класс для работы с кубиками
class Dice {
    func roll(count: Int) -> [Int] {
        return (0..<count).map { _ in Int.random(in: 1...6) }
    }
}

// Класс для работы с диапазоном урона
class DamageRange {
    let minDamage: Int
    let maxDamage: Int
    
    init(minDamage: Int, maxDamage: Int) {
        guard minDamage > 0 && maxDamage > 0 && minDamage <= maxDamage else {
            fatalError("Некорректный диапазон урона")
        }
        
        self.minDamage = minDamage
        self.maxDamage = maxDamage
    }
    
    func randomDamage() -> Int {
        return Int.random(in: minDamage...maxDamage)
    }
}

// Создание игрока
let playerDamageRange = DamageRange(minDamage: 2, maxDamage: 6)
let player = Player(attack: 15, defense: 10, maxHealth: 30, damageRange: playerDamageRange)

// Создание монстра
let monsterDamageRange = DamageRange(minDamage: 3, maxDamage: 8)
let monster = Monster(attack: 12, defense: 12, maxHealth: 30, damageRange: monsterDamageRange)

// Функция для отображения состояния существ
func showStatus() {
    print("\nСостояние существ:")
    print("Игрок: HP \(player.health)/\(player.maxHealth)")
    print("Монстр: HP \(monster.health)/\(monster.maxHealth)")
}

// Основной цикл битвы
var battleOver = false
var round = 1

while !battleOver {
    print("\n--- Раунд \(round) ---")
    
    // Ход игрока
    print("\nХод игрока:")
    player.attack(target: monster)
    showStatus()
    
    if monster.isDead() {
        print("\nМонстр повержен!")
        battleOver = true
        break
    }
    
    // Ход монстра
    print("\nХод монстра:")
    monster.attack(target: player)
    showStatus()
    
    if player.isDead() {
        print("\nИгрок повержен!")
        battleOver = true
        break
    }
    
    // Возможность исцеления игрока
    if player.health < player.maxHealth && player.healCount > 0 {
        print("\nИгрок использует исцеление")
        player.heal()
        showStatus()
    }
    
    round += 1
}

// Финальное сообщение
if player.isDead() {
    print("\nИгра окончена. Вы проиграли!")
} else {
    print("\nИгра окончена. Вы победили!")
}
