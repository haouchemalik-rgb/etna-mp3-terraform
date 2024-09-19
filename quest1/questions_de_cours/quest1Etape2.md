1. Qu'est-ce qu'un VPC ?
Un VPC (Virtual Private Cloud) est un réseau privé virtuel dans le cloud AWS. Il permet de créer et gérer des réseaux isolés dans lesquels on peut déployer des ressources telles que des machines virtuelles (EC2), des bases de données, et d'autres services AWS. Chaque VPC possède une plage d'adresses IP définie par l'utilisateur, des sous-réseaux, des tables de routage, des passerelles Internet, et peut inclure des groupes de sécurité et des ACL pour contrôler les accès.

2. Qu'est-ce qu'une ACL ?
Une ACL (Access Control List) est une liste de contrôle d'accès réseau. En AWS, une Network ACL est associée à un VPC et contrôle le trafic réseau au niveau des sous-réseaux. Elle permet de définir des règles qui autorisent ou refusent des flux entrants (ingress) et sortants (egress) basés sur des critères comme l'adresse IP, le port et le protocole. Contrairement aux Security Groups qui sont associés à des instances spécifiques, une ACL s'applique à tout un sous-réseau.

3. Qu'est-ce qu'un Subnet ?
Un Subnet (Sous-réseau) est une subdivision d'un VPC, créée en spécifiant une plage d'adresses IP plus petite que celle du VPC. Les sous-réseaux permettent d'organiser et d'isoler des ressources au sein du VPC. Ils peuvent être configurés comme publics (avec un accès à Internet) ou privés (sans accès direct à Internet). Chaque sous-réseau est associé à une zone de disponibilité (Availability Zone) spécifique dans une région AWS.

4. À quoi sert la aws_route_table ?
La Table de routage (aws_route_table) est une ressource dans AWS qui contient des règles de routage permettant de déterminer comment les paquets réseau doivent être dirigés. Les tables de routage permettent de spécifier des chemins pour le trafic réseau au sein du VPC. Par exemple, une règle de routage peut être utilisée pour envoyer tout le trafic destiné à Internet (0.0.0.0/0) vers une passerelle Internet associée au VPC.

5. À quoi sert la aws_route_table_association ?
L'aws_route_table_association associe une table de routage à un sous-réseau spécifique. Cela permet d'appliquer les règles de routage définies dans la table de routage à ce sous-réseau particulier, afin de déterminer comment les paquets circulent depuis et vers les ressources situées dans ce sous-réseau.