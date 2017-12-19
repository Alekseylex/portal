# API

## *����*

- [��������](#��������-top)
- [��������](#��������-top)
  - [*��������* - `branches`](#��������---branches-top)
  - [*ϳ�������* - `institutions`](#ϳ�������---institutions-top)
  - [*�������� ����������* - `products`](#��������-����������---products-top)
  - [*���� �������� ����������* - `products_types`](#����-��������-����������---products_types-top)
  - [*��������* - `packages`](#��������---packages-top)
  - [*�������� �������������* - `suppliers_packages`](#��������-�������������---suppliers_packages-top)
  - [*�������������* - `suppliers`](#�������������---suppliers-top)
  - [*������� ������� ������* - `children_day_costs`](#�������-�������-������---children_day_costs-top)
  - [*������� ������ ��������* - `causes_deviations`](#�������-������-��������---causes_deviations-top)
  - [*ĳ��* - `children`](#ĳ��---children-top)
  - [*������� ����* - `children_categories`](#�������-����---children_categories-top)
  - [*����� ����* - `children_groups`](#�����-����---children_groups-top)
  - [*���� ������� ����* - `children_categories_types`](#����-�������-����---children_categories_types-top)
  - [*������� ��������� ������* - `reasons_absences`](#�������-���������-������---reasons_absences-top)
  - [*������� �����* - `dishes_categories`](#�������-�����---dishes_categories-top)
  - [*������* - `dishes`](#������---dishes-top)
  - [*������� ��* - `meals`](#�������-��---meals-top)
  - [*����� �������� �������� �� ��������� ���� � �������* - `dishes_products_norms`](#�����-��������-��������-��-���������-����-�-�������---dishes_products_norms-top)
  - [*���� ���������� ���������* - `date_blocks`](#����-����������-���������---date_blocks-top)
- [���������](#���������-top)
  - [*���������� �������������* - `supplier_orders`](#����������-�������������---supplier_orders-top)
  - [*����������� ���* - `receipts`](#�����������-���---receipts-top)
  - [*���������� �������� ����������* - `institution_orders`](#����������-��������-����������---institution_orders-top)
  - [*����������� ���������� �������� ����������* - `io_corrections`](#�����������-����������-��������-����������---io_corrections-top)
  - [*����-������* - `menu_requirements`](#����-������---menu_requirements-top)
  - [*������* - `timesheets`](#������---timesheets-top)

## �������� [:top:](#����)

����������� ��������� ��� ������ � API - [**Postman**](https://www.getpostman.com/)

**�������� ��������� ������:**

POST | /api/cu_supplier | { "code": "25", "name": "��� ������ � 25" }
-|-|-
��� ������ | ������ �� ������ ������� | ҳ�� ������

![postman_post](https://user-images.githubusercontent.com/24915025/26839046-8f3d7ef0-4aea-11e7-8a11-bd246f5c2aa2.png)

����� | ����
-|-
GET | ��������� ������. ������� � ������ (��������� �� `-s(-es)`), **��������� �� �������** - ����� ����� ������� �� ���. ��������� `GET /api/cu_suppliers`.
POST | ����������� ������
DELETE | ��������� ����� (`"type": 0` ������� ������� ����� � ������� )

## �������� [:top:](#����)

### *��������* - `branches` [:top:](#����)

```json
POST /api/cu_institution { "code": "14", "name": "18 (���)", "prefix": "�18", "branch_code": "00000000003" }
GET /api/institution?code=14
GET /api/institutions
```

### *ϳ�������* - `institutions` [:top:](#����)

```json
POST /api/cu_institution { "code": "14", "name": "18 (���)", "prefix": "�18", "branch_code": "00000000003" }
GET /api/institution?code=14
GET /api/institutions
```

### *�������� ����������* - `products` [:top:](#����)

```json
POST /api/cu_product { "code": "00000000079", "name": "���������", "products_type_code": "000000001" }
GET /api/product?code=000000079
GET /api/products
```

### *���� �������� ����������* - `products_types` [:top:](#����)

```json
POST /api/cu_products_type { "code": "000000001", "name": "������ � ������", "priority": 1 }
GET /api/products_type?code=000000001
GET /api/products_types
```

### *��������* - `packages` [:top:](#����)

```json
POST /api/cu_package { "code": "000000001", "name": "ѳ��� 5 ��", "conversion_factor": 5.000000 }
GET /api/package?code=000000001
GET /api/packages
```

### *�������� �������������* - `suppliers_packages` [:top:](#����)

```json
POST /api/cu_suppliers_package { "institution_code": "14", "supplier_code": "8", "product_code": "00000000079", "package_code": "000000001", "period": "1496448000", "activity": 1 }
GET /api/suppliers_package?institution_code=14&supplier_code=8&product_code=00000000079&package_code=000000001&period=2017-05-03
GET /api/suppliers_packages
```

### *�������������* - `suppliers` [:top:](#����)

```json
POST /api/cu_supplier { "code": "25", "name": "��� ������ � 25" }
GET /api/supplier?code=16
GET /api/suppliers
```

### *������� ������� ������* - `children_day_costs` [:top:](#����)

```json
POST /api/cu_children_day_cost { "children_category_code": "000000001", "cost_date": "1485296673", "cost": 12.25 }
GET /children_day_cost?children_category_code=000000001&cost_date=2017-01-25
GET api/children_day_costs
```

### *������� ������ ��������* - `causes_deviations` [:top:](#����)

```json
  POST /api/cu_causes_deviation { "code": "000000002", "name": "������� 2" }
  GET /api/causes_deviation?code=000000002
  GET /api/causes_deviations
```

### *ĳ��* - `children` [:top:](#����)

```json
POST /api/cu_child { "code": "000000001", "name": "������ ���� ��������" }
GET /api/child?code=000000001
GET /api/children
```

### *������� ����* - `children_categories` [:top:](#����)

```json
POST /api/cu_children_category { "code": "000000001", "name": "���", "priority": 1, "children_categories_type_code": "000000001" }
GET /api/children_category?code=000000001
GET /api/children_categories
```

### *����� ����* - `children_groups` [:top:](#����)

```json
POST /api/cu_children_group { "code": "000000003", "name": "3\1", "children_category_code": "000000001", "institution_code": "14"}
GET /api/children_group?code=000000003
GET /api/children_groups
```

### *���� ������� ����* - `children_categories_types` [:top:](#����)

```json
POST /api/cu_children_categories_type { "code": "00000001", "name": "���������" }
GET /api/children_categories_type?code=16
GET /api/children_categories_types
```

### *������� ��������� ������* - `reasons_absences` [:top:](#����)

```json
POST /api/cu_reasons_absence { "code": "000000001", "mark": "�", "name": "�������" }
GET /api/reasons_absence?code=000000001
GET /api/reasons_absences
```

### *������� �����* - `dishes_categories` [:top:](#����)

```json
POST /api/cu_dishes_categories { "dishes_categories": [ { "code": "000000001", "name": "����� ������", "priority": 1 }, { "code": "000000002", "name": "����� ������", "priority": 2 } ] }
GET /api/dishes_category?code=000000002
GET /api/dishes_categories
```

### *������* - `dishes` [:top:](#����)

```json
POST /api/cu_dishes { "dishes": [ { "code": "000000003", "name": "���", "dishes_category_code": "000000001", "priority": 4 }, { "code": "000000004", "name": "���", "dishes_category_code": "000000002", "priority": 3 } ] }
GET /api/dish?code=000000001
GET /api/dishes
```

### *������� ��* - `meals` [:top:](#����)

```json
POST /api/cu_meals { "meals": [ { "code": "000000001", "name": "�������", "priority": 1 }, { "code": "000000002", "name": "���", "priority": 2 } ] }
GET /api/meal?code=000000002
GET /api/meals
```

### *����� �������� �������� �� ��������� ���� � �������* - `dishes_products_norms` [:top:](#����)

```json
POST /api/cu_dishes_products_norms
{ "dishes_products_norms":
  [
    { "institution_code": 14, "dish_code": "000000002", "product_code": "000000054", "children_category_code": "000000001", "amount": 0.01 },
    { "institution_code": 14, "dish_code": "000000002", "product_code": "000000047", "children_category_code": "000000001", "amount": 0.05 }
  ]
}
```

### *���� ���������� ���������* - `date_blocks` [:top:](#����)

```json
  POST /api/cu_date_blocks
  { "date_blocks":
    [
      { "institution_code": 14, "date_start": 1509494400, "date_end": 1510576706 }
    ]
  }

  DELETE /api/date_blocks
  { "date_blocks":
    [
      { "institution_code": 14, "date_start": 1509494400, "date_end": 1510576706 }
    ]
  }
```

## ��������� [:top:](#����)

### *���������� �������������* - `supplier_orders` [:top:](#����)

```json
POST /api/cu_supplier_order { "branch_code": "00000000006", "supplier_code": "00000000023", "number": "��000000001", "date": 1504001724, "date_start": 1498867200, "date_end": 1519862400, "products": [ { "institution_code": "14", "product_code": "000000079", "contract_number": "BX-0000001", "contract_number_manual": "��000000001", "date": 1495542284, "count": 12, "price": 10.05}, {"institution_code": "14", "product_code": "000000046  ", "contract_number": "BX-0000001", "contract_number_manual": "", "date": 1495628684, "count": 15, "price": 17.12 } ] }
GET api/supplier_order?supplier_order?branch_code=0003&number=00000011
DELETE api/supplier_order { "branch_code": "00000000003", "number": "000000000006", "type": 1 }
```

### *����������� ���* - `receipts` [:top:](#����)

```json
POST /api/cu_receipt { "institution_code": "14", "supplier_order_number": "000000000002", "contract_number": "��-000000001", "number": "0000000000011", "invoice_number": "00000012", "date": "1485296673", "date_sa": "1485296673", "number_sa": "000000000001", "products": [ { "product_code": "000000079", "date": "1504224000", "count": 25, "count_invoice": 25, "causes_deviation_code": "" }, { "product_code": "000000046", "date": "1504224000", "count": 19, "count_invoice": 30, "causes_deviation_code": "000000002" } ] }
GET /api/receipt?/receipt?institution_code=14&number=KL-000000005
DELETE /api/receipt { "institution_code": "14", "number": "000000000002" }
```

### *���������� �������� ����������* - `institution_orders` [:top:](#����)

```json
POST /api/cu_institution_order { "institution_code": "14", "number": "000000000002", "date": "1485296673", "date_start": "1485296673", "date_end": "1485296673", "date_sa": "1485296673", "number_sa": "000000000001", "products": [ { "date": "1485296673", "product_code": "000000079  ", "count": 15, "description": "1 �������"}, { "date": "1485296673", "product_code": "000000048  ", "count": 15, "description": "1 �������,3 �������" } ] }
GET api/institution_order?institution_code=14&number=000000000002
DELETE api/institution_order { "institution_code": "14", "number": "KL-000000013", "type": 1 }
```

### *����������� ���������� �������� ����������* - `io_corrections` [:top:](#����)

```json
POST /api/cu_institution_order_correction { "institution_code": "14", "institution_order_number": "KL-000000058", "number": "000000000004", "date": "1485296673", "date_sa": "1485296673", "number_sa": "000000000001",
"products": [ { "date": "1485296673", "product_code": "000000079  ", "amount_order": 5, "amount": 7, "description": "1 �������" }, { "date": "1485296673", "product_code": "000000048  ", "amount_order": 8, "amount": 8, "description": "1 �������,3 �������" } ] }
GET /api/institution_order_correction?institution_code=14&institution_order_number=000000000002&number=000000000010
DELETE /api/institution_order_correction { "institution_code": "14", "institution_order_number": "KL-000000053", "number": "KL-000000022",  "type": 1 }
```

### *����-������* - `menu_requirements` [:top:](#����)

- ����

```json
POST /api/cu_menu_requirement_plan { "branch_code": "0003", "institution_code": "14", "number": "000000000002", "date": "1485296673", "splendingdate": "1485296673", "date_sap": "1485296673", "number_sap": "000000000001", "children_categories": [ { "children_category_code": "000000001", "count_all_plan": 55, "count_exemption_plan": 19 }, { "children_category_code": "000000002", "count_all_plan": 3, "count_exemption_plan": 7 } ], "products": [ { "children_category_code": "000000001", "product_code": "000000079  ", "count_plan": 15 }, { "children_category_code": "000000002", "product_code": "000000079  ", "count_plan": 21 } ] }

DELETE api/menu_requirement { "institution_code": "14", "number": "KL-000000024", "type": 1 }
```

- ����

```json
POST /api/cu_menu_requirement_fact { "branch_code": "0003", "institution_code": "14", "number": "000000000002", "date": "1485296673", "splendingdate": "1485296673", "date_saf": "1485296673", "number_saf": "000000000001", "children_categories": [ { "children_category_code": "000000001", "count_all_fact": 55, "count_exemption_fact": 19 }, { "children_category_code": "000000002", "count_all_fact": 3, "count_exemption_fact": 7 } ], "products": [ { "children_category_code": "000000001", "product_code": "000000079  ", "count_fact": 15 }, { "children_category_code": "000000002", "product_code": "000000079  ", "count_fact": 21 } ] }

DELETE api/menu_requirement { "institution_code": "14", "number": "KL-000000024", "type": 2 }
```

- �������� ���������

```json
  GET api/menu_requirement?institution_code=14&number=000000000028
```

- ���� ���������

```json
  GET /api/print_menu_requirement?institution_code=14&number=018�-0000121
```

### *������* - `timesheets` [:top:](#����)

```json
POST /api/cu_timesheet { "branch_code": "0003", "institution_code": "14", "number": "000000000002", "date": "1487548800", "date_vb": "1485907200", "date_ve": "1488240000", "date_eb": "1485907200", "date_ee": "1486684800", "date_sa": "1506902400", "number_sa": "000000000001", "dates": [ { "child_code": "000000001", "children_group_code": "000000001", "reasons_absence_code": "000000001", "date": "1485907200" }, { "child_code": "000000001", "children_group_code": "000000001", "reasons_absence_code": "000000001", "date": "1485993600" } ] }
GET api/timesheet?institution_code=14&number=000000000001
DELETE api/timesheet { "institution_code": "14", "number": "KL-000000028", "type": 1 }
```