
--  Exercice 1 Programmation des vues
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS v_gescom_catalogue; 
CREATE VIEW v_gescom_catalogue

-- Ceci corresponds a la selection des vues de plusieurs catégories puis des colone requisent
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
AS SELECT  `pro_ref` ,`pro_id`,`cat_name`, `cat_id`
from `produit`
join `categorie` on `cat_id` = `pro_cat_id`;
-----------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
-- Exercice 2 programmer des procédures stockées
-- ici c'est la procédure de facturation à donner.

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS facturation|   
CREATE PROCEDURE facturation
(
   in `p_Num_Com`    int(10)
)
BEGIN
    DECLARE `Num_Comm_verif`   varchar(50);
    SET `Num_Comm_verif` = (
        SELECT `order_id`
        FROM `order`
        WHERE `order_id` = `p_Num_Com`
    );
    
    IF ISNULL(`Num_Com_verif`)
	THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "le numéro de commande est inconnu";
    ELSE
		SELECT  
				commande.ord_order_date AS 'Date',
				commande.ord_id AS 'Numero de la commande',
				CONCAT(commande.custom_firstname, ' ', commande.custom_lastname, ' à ', commande.custom_city) AS 'Client',
                produits.ode_id AS 'Ligne de la commande',
                CONCAT(produit.ode_unit_price, 2), '€') AS 'Prix à l unité',
                CONCAT(produit.pro_ref, '  ', produit.pro_name, '  ', produit.pro_color) AS 'Produit',
                produit.ode_quantity AS 'Quantité du produit',
                CONCAT(produit.ode_discount, '%') AS 'Remise',
                CONCAT(ROUND(totcom.total, 2), '€') AS 'Total'
                FROM (
            SELECT * FROM `order`
            INNER JOIN `customer` ON `ord_cus_id` = `custom_id`
            WHERE `order_id` = `p_Num_Com`
        ) com,
        (
            SELECT * FROM `order`
            INNER JOIN `produit` ON `ode_produit_id` = `produit_id`
			INNER JOIN `order_details` ON `order_id` = `ode_order_id`
            WHERE `order_id` = `p_Num_Com`
        ) produits,
        (
            SELECT SUM((`ode_quantity` * `ode_unit_price`) * ((100-`ode_discount`)/100)) AS 'total final'
            FROM `order`
            INNER JOIN `order_details` ON `order_id` = `ode_order_id`
            WHERE `order_id` = `p_Num_Com`
        ) totcom;
END |
 ;
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

-- Exercice 3 Programmer les trigger

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------


CREATE table commandes_articles (
        `code`  int (50),
        `quote` int (50),
        `date`  date not null,
    constraint commandes_articles_codes_FK foreign KEY (code) references produit(produit_id),
    constraint commandes_articles_PK PRIMARY KEY (code)
);
-------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


CREATE TRIGGER after_produit_update
after update 
on `produit`
FOR EACH ROW

BEGIN
    DECLARE `new_quote` int(10);
    DECLARE `id_produit` int(10);
	DECLARE `produit_stock` int(10);
    DECLARE `produit_alert` int(10);
    DECLARE `verification` varchar(50);
    ---------------------------------------
    ---------------------------------------
    SET `produit_stock` = NEW.produit_stock;
	SET `id_produit` = NEW.produit_id;
    SET `produit_alert` = NEW.produit_stock_alert;
   
    ---------------------------------------
    ---------------------------------------
    


    if (`produit_stock`<`produit_alert`)
THEN

    SET `verification` = (
        SELECT `code`
        FROM `commandes_articles`
        WHERE `code` = `id_produit`
    );
    IF ISNULL(`verification`)
        THEN
            insert into commandes_articles
            (`code`, `quote`)
            values
            (id_prod, new_qte ());
        ELSE
            update commandes_articles
            SET `quote` = new_quote , 
                `date` = CURRENT_DATE()
            WHERE `code` = `id_produit`;
    ELSE 
        delete
        from commandes_articles
        WHERE `code` = `id_produit`;

END | 

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
