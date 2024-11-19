package edu.uniquindio.redmultinivel.redmultinivel.controller;

import javafx.event.ActionEvent;
import javafx.scene.control.Alert;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class RegistroView {
    public TextField cedulaTextField;
    public TextField nombreTextField;
    public TextField apellidoTextField;
    public TextField dirrecionTextField;
    public TextField correoTextField;
    public PasswordField contrasenaPasswordField;
    public PasswordField confirmarContrasenaPasswordField;
    public TextField textFieldParentAffiliateId;

    private void mostrarAlerta(String mensaje) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle("Error de Registro");
        alert.setHeaderText(null);
        alert.setContentText(mensaje);
        alert.showAndWait();
    }
    private void limpiarCampos() {
        cedulaTextField.setText("");
        nombreTextField.setText("");
        apellidoTextField.setText("");
        correoTextField.setText("");
        dirrecionTextField.setText("");
        contrasenaPasswordField.setText("");
        confirmarContrasenaPasswordField.setText("");
    }

    public void registrarCuenta(ActionEvent actionEvent) {
        // Capturar los valores ingresados
        String affiliateId = cedulaTextField.getText();
        String firstName = nombreTextField.getText();
        String lastName = apellidoTextField.getText();
        String email = correoTextField.getText();
        String address = dirrecionTextField.getText();
        String contrasenia = contrasenaPasswordField.getText();
        String contraseniaConfirm = confirmarContrasenaPasswordField.getText();

       //String hierarchicalLevel = textFieldHierarchicalLevel.getText();
        String parentAffiliateId = textFieldParentAffiliateId.getText();

        if (affiliateId.isEmpty()|| firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || address.isEmpty()) {
            mostrarAlerta("Todos los campos son obligatorios.");
            return;
        }
        if(!contrasenia.equals(contraseniaConfirm)){
            mostrarAlerta("Las contraseñas no coinciden");
            return;
        }
        // Conexión a la base de datos y ejecución del procedimiento
        try (Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "felipe", "12345")) {
            String sql = "{CALL insertar_affiliate(?, ?, ?, ?, ?, ?, ?, ?)}";
            try (CallableStatement callableStatement = connection.prepareCall(sql)) {
                callableStatement.setInt(1, Integer.parseInt(affiliateId));
                callableStatement.setString(2, firstName);
                callableStatement.setString(3, lastName);
                callableStatement.setString(4, email);
                callableStatement.setString(5, contrasenia);
                callableStatement.setInt(6, 1); // Activar
                callableStatement.setString(7, address);
                //Esto es un trigger
                //callableStatement.setInt(8, Integer.parseInt(hierarchicalLevel));
                callableStatement.setObject(9, parentAffiliateId.isEmpty() ? null : Integer.parseInt(parentAffiliateId));

                callableStatement.execute();

                // Mostrar mensaje de éxito
                Alert alert = new Alert(Alert.AlertType.INFORMATION);
                alert.setTitle("Éxito");
                alert.setHeaderText(null);
                alert.setContentText("Afiliado agregado exitosamente.");
                alert.showAndWait();
            }
        } catch (SQLException | NumberFormatException e) {
            // Mostrar mensaje de error
            Alert alert = new Alert(Alert.AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("No se pudo agregar el afiliado: " + e.getMessage());
            alert.showAndWait();
        }
        limpiarCampos();
    }

    public void salir(ActionEvent actionEvent) {
    }
}
