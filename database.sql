CREATE TABLE IF NOT EXISTS criminal_empires (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    leader INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS criminal_empire_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empire_id INT NOT NULL,
    player_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empire_id) REFERENCES criminal_empires(id),
    FOREIGN KEY (player_id) REFERENCES users(identifier)
);

CREATE TABLE IF NOT EXISTS criminal_empire_territories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empire_id INT NOT NULL,
    territory_id INT NOT NULL,
    captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empire_id) REFERENCES criminal_empires(id)
);