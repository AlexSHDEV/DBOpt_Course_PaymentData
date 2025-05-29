USE PaymentData;
GO

DECLARE @iter INT = 0;
DECLARE @max_iter INT = 500;
DECLARE @startTime DATETIME, @endTime DATETIME, @duration DECIMAL(18,2);

PRINT 'Начало вставки платежей...';

SET @startTime = GETUTCDATE();

WHILE @iter < @max_iter
BEGIN
  DECLARE @r_payee UNIQUEIDENTIFIER = (SELECT TOP (1) PaymentParticipant.Oid FROM dbo.PaymentParticipant ORDER BY NEWID());
  DECLARE @r_payer UNIQUEIDENTIFIER = (SELECT TOP (1) PaymentParticipant.Oid FROM dbo.PaymentParticipant ORDER BY NEWID());
  DECLARE @r_category UNIQUEIDENTIFIER = (SELECT TOP (1) PaymentCategory.Oid FROM dbo.PaymentCategory ORDER BY NEWID());
  DECLARE @r_project UNIQUEIDENTIFIER = (SELECT TOP (1) Project.Oid FROM dbo.Project ORDER BY NEWID());

  INSERT dbo.Payment(
    Oid, 
    Amount, 
    Category, 
    Project, 
    Justification, 
    Comment, 
    Date, 
    Payer, 
    Payee, 
    OptimisticLockField, 
    GCRecord, 
    CreateDate, 
    CheckNumber, 
    IsAuthorized, 
    Number
  ) VALUES (
    NEWID(), 
    79, 
    @r_category, 
    @r_project, 
    '0P0', 
    'test', 
    '2023-06-05 00:00:00.000', 
    @r_payer, 
    @r_payee, 
    -6673, 
    5412, 
    '2023-07-05 00:00:00.000', 
    N'1234', 
    0, 
    N'12312'
  );

  SET @iter = @iter + 1;
END;

SET @endTime = GETUTCDATE();
SET @duration = DATEDIFF(ms, @startTime, @endTime);

PRINT 'Вставка платежей завершена.';
PRINT 'Время выполнения: ' + CAST(@duration AS VARCHAR(20)) + ' мс';
