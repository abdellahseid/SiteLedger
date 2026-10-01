import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// 1. Cached Projects
class CachedProjects extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  RealColumn get budgetEtb => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Cached Purchase Orders
class CachedOrders extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get poNumber => text()();
  TextColumn get supplierName => text()();
  TextColumn get status => text()();
  RealColumn get totalAmountEtb => real()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Cached Receipts
class CachedReceipts extends Table {
  TextColumn get id => text()();
  TextColumn get receiptNumber => text()();
  TextColumn get poId => text()();
  TextColumn get poNumber => text()();
  TextColumn get projectId => text()();
  TextColumn get projectName => text()();
  TextColumn get supplierName => text()();
  TextColumn get waybillNumber => text()();
  TextColumn get truckLicensePlate => text()();
  TextColumn get driverName => text()();
  TextColumn get status => text()(); // SUBMITTED, FLAGGED, PENDING_SYNC
  TextColumn get notes => text().nullable()();
  DateTimeColumn get deliveryTimestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Cached Discrepancies
class CachedDiscrepancies extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get projectName => text()();
  TextColumn get receiptId => text()();
  TextColumn get receiptNumber => text()();
  TextColumn get materialName => text()();
  TextColumn get type => text()(); // SHORTAGE, EXCESS, DAMAGE
  TextColumn get severity => text()(); // LOW, MEDIUM, HIGH, CRITICAL
  TextColumn get status => text()(); // OPEN, UNDER_REVIEW, RESOLVED
  RealColumn get expectedQuantity => real()();
  RealColumn get actualQuantity => real()();
  RealColumn get varianceQuantity => real()();
  RealColumn get financialImpactEtb => real()();
  TextColumn get description => text()();
  TextColumn get assignedToName => text().nullable()();
  TextColumn get resolutionNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Offline Sync Outbox Queue
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get actionType => text()(); // RECEIVE_DELIVERY
  TextColumn get payloadJson => text()(); // Full JSON payload
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCING, FAILED, COMPLETED
  TextColumn get errorMessage => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}

@DriftDatabase(tables: [
  CachedProjects,
  CachedOrders,
  CachedReceipts,
  CachedDiscrepancies,
  SyncOutbox,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'siteledger_local_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
