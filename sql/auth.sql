-- --------------------------------------------------------
-- Host:                       127.0.0.1
-- Server-Version:             8.4.0 - MySQL Community Server - GPL
-- OS:                         Windows 11
-- SQLYog Community Version:   13.3.0
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Import tables to acore_auth

CREATE TABLE IF NOT EXISTS `account_transmog` (
  `account_id` int unsigned NOT NULL,
  `unlocked_item_id` int unsigned NOT NULL,
  `inventory_type` int unsigned DEFAULT NULL,
  `display_id` int unsigned NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  UNIQUE KEY `account_item_id` (`account_id`,`unlocked_item_id`) USING BTREE,
  UNIQUE KEY `account_display_id` (`account_id`,`display_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `account_transmog_sets` (
    `account_id` INT UNSIGNED NOT NULL,
    `set_id` INT UNSIGNED NOT NULL,
    `slot` INT UNSIGNED NOT NULL,
    `item_transmog_display` INT UNSIGNED NOT NULL,
    `set_name` VARCHAR(25) NOT NULL,
    PRIMARY KEY (`account_id`, `set_id`, `slot`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
