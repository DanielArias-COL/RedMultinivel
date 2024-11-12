module edu.uniquindio.redmultinivel.redmultinivel {
    requires javafx.controls;
    requires javafx.fxml;
    requires java.naming;

    requires org.controlsfx.controls;
    requires org.kordamp.bootstrapfx.core;
    requires java.sql;
    requires com.oracle.database.jdbc;
    requires java.desktop;
    requires static lombok;

    opens edu.uniquindio.redmultinivel.redmultinivel to javafx.fxml;
    exports edu.uniquindio.redmultinivel.redmultinivel;
    exports edu.uniquindio.redmultinivel.redmultinivel.controller;
    opens edu.uniquindio.redmultinivel.redmultinivel.controller to javafx.fxml;
    opens edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos to javafx.base;
}