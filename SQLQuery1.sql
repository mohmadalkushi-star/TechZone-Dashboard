
/*
الشرح التقني: يقوم الاستعلام بربط جداول الطلبات بالمنتجات بالتصنيفات، ثم يحسب الربح لكل صف (سعر البيع - سعر التكلفة × الكمية) ويجمعه حسب اسم التصنيف.

رؤية البزنس: تحديد "محركات الربح". يساعد هذا الاستعلام في معرفة أي التصنيفات هي الأكثر ربحية، مما يوجه ميزانيات التسويق والمخزون نحو التصنيفات التي تدر أموالاً أكثر للشركة، وليس فقط التي تبيع أكثر.
*/
SELECT 
    c.CategoryName,
    SUM((p.SellingPrice - p.CostPrice) * o.Quantity) AS TotalProfit
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalProfit DESC;




/*
الشرح التقني: يربط الفروع بالتصنيفات ويحسب الأرباح، مع استخدام HAVING لتصفية النتائج وعرض قسم "الإلكترونيات" فقط.

رؤية البزنس: تحليل أداء جغرافي متخصص. بدلاً من النظر للشركة ككل، نحن نقارن أداء فروعنا في بيع "الإلكترونيات". كما ذكرتَ، هذا يكشف أن بعض الفروع (مثل ينبع والدمام) هي قادة الأداء، مما يطرح سؤالاً إدارياً: "ما هي الممارسات الناجحة في ينبع لنقلها للفروع الأخرى؟".
*/
SELECT 
    branch.BranchName,
    c.CategoryName,
    SUM((p.SellingPrice - p.CostPrice) * o.Quantity) AS TotalProfit
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Branches branch ON o.BranchID = branch.BranchID
GROUP BY branch.BranchName, c.CategoryName
HAVING CategoryName = ('إلكترونيات')
ORDER BY TotalProfit DESC;



/*
الشرح التقني: استخدام CTE لتلخيص البيانات أولاً (تكلفة، مبيعات، ربح) ثم حساب هامش الربح كنسبة مئوية من المبيعات لضمان الدقة وتجنب القسمة على صفر.

رؤية البزنس: قياس الكفاءة التشغيلية. ليس المهم فقط "كم بعنا"، بل "كم أبقينا من كل ريال مبيعات". المدينة ذات هامش الربح الأعلى هي الأكثر كفاءة في إدارة التكاليف، وهذا الاستعلام يكشف الفرق الجوهري بين المبيعات (حجم العمل) والربحية (كفاءة العمل).
*/
WITH FinancialSummary AS (
SELECT
Branches.City,
SUM(Products.CostPrice * Orders.Quantity) AS TotalCost,
SUM(Products.SellingPrice * Orders.Quantity) AS TotalSales,
SUM((Products.SellingPrice - Products.CostPrice) * Orders.Quantity) AS TotalProfit 
FROM Branches
JOIN Orders ON Branches.BranchID = Orders.BranchID
JOIN Products ON Orders.ProductID = Products.ProductID
GROUP BY Branches.City
)
SELECT
City , 
TotalCost,
TotalSales,
TotalProfit ,
(TotalProfit/NULLIF(TotalSales, 0) )* 100 AS ProfitMarginPercentage
FROM FinancialSummary
ORDER BY ProfitMarginPercentage DESC;




/*
الشرح التقني: استخدام LEFT JOIN يضمن عدم استبعاد أي عميل (حتى من لم يشترِ)، والتجميع باستخدام CustomerID يضمن دقة البيانات حتى لو تشابهت الأسماء.

رؤية البزنس: تقسيم العملاء (Customer Segmentation). يساعد في التعرف على:

العملاء الأوفياء: (أعلى مبيعات).

العملاء النائمين: (من لديهم 0 طلبات، وهم من يجب استهدافهم بحملات استعادة العملاء).
*/
SELECT 
    Customers.CustomerID, 
    Customers.CustomerName, 
    COUNT(Orders.OrderID) AS TotalOrders,
    SUM(Products.SellingPrice * Orders.Quantity) AS TotalSales
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
LEFT JOIN Products ON Orders.ProductID = Products.ProductID
GROUP BY Customers.CustomerID, Customers.CustomerName;      




