-- Генерация данных
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- 1. Создаем базовых участников (PaymentParticipant)
    DECLARE @Participants TABLE (ID INT IDENTITY, Oid UNIQUEIDENTIFIER, ObjectType INT);
    
    -- Генерация 100 участников
    DECLARE @i INT = 1;
    WHILE @i <= 100
    BEGIN
        DECLARE @ObjectType INT = ROUND(RAND() * 4, 0);
        DECLARE @Oid UNIQUEIDENTIFIER = NEWID();
        
        INSERT INTO PaymentParticipant (Oid, Balance, Name, OptimisticLockField, GCRecord, ObjectType, 
                                      ActiveFrom, InactiveFrom, BankDetails, Balance2, Balance3)
        VALUES (@Oid, ROUND(RAND() * 1000000, 0), 'Participant ' + CAST(@i AS VARCHAR(10)), 
               1, NULL, @ObjectType, 
               DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'), NULL, 
               'Bank details ' + CAST(@i AS VARCHAR(10)), ROUND(RAND() * 1000000, 0), ROUND(RAND() * 1000000, 0));
        
        INSERT INTO @Participants (Oid, ObjectType) VALUES (@Oid, @ObjectType);
        SET @i = @i + 1;
    END;
    
    -- 2. Заполняем специализированные таблицы
    
    -- Клиенты (ObjectType = 2)
    INSERT INTO Client (Oid, FirstName, SecondName, Phone)
    SELECT p.Oid, 
           'Client ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)),
           'Client ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)),
           '555-' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)) + '-1234'
    FROM @Participants p
    WHERE p.ObjectType = 2;
    
    -- Сотрудники (ObjectType = 3)
    DECLARE @Employees TABLE (ID INT IDENTITY, Oid UNIQUEIDENTIFIER);
    
    INSERT INTO Employee (Oid, BusyUntil, SecondName, Stuff, HourPrice, Patronymic, PlanfixId, Head, PlanfixMoneyRequestTask)
    SELECT p.Oid, 
           DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'),
           'Employee ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)),
           ROUND(RAND() * 10, 0), 
           ROUND(RAND() * 100, 0), 
           'Patronymic ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)),
           ROUND(RAND() * 1000, 0), 
           NULL, 
           'Planfix task ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10))
    FROM @Participants p
    WHERE p.ObjectType = 3;
    
    INSERT INTO @Employees (Oid)
    SELECT Oid FROM Employee;
   
    
    -- Поставщики (ObjectType = 4)
    INSERT INTO Supplier (Oid, Contact, ProfitByMaterialAsPayer, ProfitByMaterialAsPayee, CostByMaterialAsPayer)
    SELECT p.Oid, 
           'Supplier ' + CAST(ROW_NUMBER() OVER (ORDER BY p.Oid) AS VARCHAR(10)),
           ROUND(RAND(), 0), 
           ROUND(RAND(), 0), 
           ROUND(RAND(), 0)
    FROM @Participants p
    WHERE p.ObjectType = 4;
    
    -- Кассы (ObjectType = 0)
    INSERT INTO Cashbox (Oid, AccountType)
    SELECT p.Oid, 
           (SELECT TOP 1 Oid FROM AccountType ORDER BY NEWID())
    FROM @Participants p
    WHERE p.ObjectType = 0;
    
    -- Банковские счета (ObjectType = 1)
    INSERT INTO Bank (Oid, AccountType)
    SELECT p.Oid, 
           (SELECT TOP 1 Oid FROM AccountType ORDER BY NEWID())
    FROM @Participants p
    WHERE p.ObjectType = 1;
    
    -- 3. Создаем проекты
    DECLARE @Projects TABLE (ID INT IDENTITY, Oid UNIQUEIDENTIFIER);
    
    INSERT INTO Project (Oid, Name, Address, Client, Manager, Foreman, 
                        OptimisticLockField, GCRecord, Balance, BalanceByMaterial, 
                        BalanceByWork, PlaningStartDate, Status, FinishDate, 
                        Area, WorkPriceRate, WorkersPriceRate, RemainderTheAdvance, 
                        PlanfixWorkTask, PlanfixChangeRequestTask, UseAnalytics)
    SELECT NEWID(),
           'Project ' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) AS VARCHAR(10)),
           'Address ' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) AS VARCHAR(10)),
           (SELECT TOP 1 Oid FROM Client ORDER BY NEWID()),
           (SELECT TOP 1 Oid FROM Employee ORDER BY NEWID()),
           (SELECT TOP 1 Oid FROM Employee ORDER BY NEWID()),
           1, NULL, 
           ROUND(RAND() * 1000000, 0), ROUND(RAND() * 1000000, 0), ROUND(RAND() * 1000000, 0),
           DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'),
           ROUND(RAND() * 5, 0),
           DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'),
           ROUND(RAND() * 1000, 0),
           RAND() * 100, RAND() * 50,
           ROUND(RAND() * 1000000, 0),
           'Planfix work task ' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) AS VARCHAR(10)),
           'Planfix change request task ' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) AS VARCHAR(10)),
           ROUND(RAND(), 0)
    FROM (SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as n FROM sys.objects) as nums;
    
    INSERT INTO @Projects (Oid)
    SELECT Oid FROM Project;
    
    -- 4. Генерация платежей
    DECLARE @j INT = 1;
    WHILE @j <= 100
    BEGIN
        INSERT INTO Payment (Oid, Amount, Category, Project, Justification, Comment, 
                         Date, Payer, Payee, OptimisticLockField, GCRecord, 
                         CreateDate, CheckNumber, IsAuthorized, Number)

        VALUES (NEWID(),
           ROUND(RAND() * 100000, 0),
           (SELECT TOP 1 Oid FROM PaymentCategory ORDER BY NEWID()),
           (SELECT TOP 1 Oid FROM @Projects ORDER BY NEWID()),
           'Justification ' + CAST(@i AS VARCHAR(10)),
           'Comment ' + CAST(@i AS VARCHAR(10)),
           DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'),
           (SELECT TOP 1 Oid FROM PaymentParticipant ORDER BY NEWID()),
           (SELECT TOP 1 Oid FROM PaymentParticipant ORDER BY NEWID()),
           1, NULL,
           DATEADD(day, ROUND(RAND() * 365, 0), '2022-01-01'),
           'Check ' + CAST(@i AS VARCHAR(10)),
           ROUND(RAND(), 0),
           'Number ' + CAST(@i AS VARCHAR(10)));
        
        SET @j = @j + 1;
    END;
    COMMIT TRANSACTION;
    PRINT 'Тестовые данные успешно сгенерированы';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка при генерации тестовых данных: ' + ERROR_MESSAGE();
END CATCH;
GO
