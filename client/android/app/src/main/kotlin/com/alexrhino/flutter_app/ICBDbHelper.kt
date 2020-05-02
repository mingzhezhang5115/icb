package com.alexrhino.flutter_app

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.provider.BaseColumns

object ICBReaderContract {
    // Table contents are grouped together in an anonymous object.
    object ICBEntry : BaseColumns {
        const val TABLE_NAME = "icb"
        const val COLUMN_NAME_URI = "uri"
        const val COLUMN_NAME_UPLOADED = "uploaded"
    }
}
private const val SQL_CREATE_ENTRIES =
        "CREATE TABLE ${ICBReaderContract.ICBEntry.TABLE_NAME} (" +
                "${BaseColumns._ID} INTEGER PRIMARY KEY," +
                "${ICBReaderContract.ICBEntry.COLUMN_NAME_URI} TEXT," +
                "${ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED} INTEGER NOT NULL CHECK (${ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED} IN (0,1)))"

private const val SQL_DELETE_ENTRIES = "DROP TABLE IF EXISTS ${ICBReaderContract.ICBEntry.TABLE_NAME}"

class ICBDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {


    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(SQL_CREATE_ENTRIES)
    }
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // This database is only a cache for online data, so its upgrade policy is
        // to simply to discard the data and start over
        db.execSQL(SQL_DELETE_ENTRIES)
        onCreate(db)
    }
    override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        onUpgrade(db, oldVersion, newVersion)
    }
    companion object {
        // If you change the database schema, you must increment the database version.
        const val DATABASE_VERSION = 1
        const val DATABASE_NAME = "ICBReader.db"
    }
}
