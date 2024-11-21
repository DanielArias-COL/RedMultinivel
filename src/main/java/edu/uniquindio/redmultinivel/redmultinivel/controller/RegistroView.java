package edu.uniquindio.redmultinivel.redmultinivel.controller;

import edu.uniquindio.redmultinivel.redmultinivel.data.AffiliateData;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Alert;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

public class RegistroView {

    @FXML
    private TextField cedulaTextField;

    @FXML
    private TextField nombreTextField;

    @FXML
    private TextField apellidoTextField;

    @FXML
    private TextField dirrecionTextField;

    @FXML
    private TextField correoTextField;

    @FXML
    private PasswordField contrasenaPasswordField;

    @FXML
    private PasswordField confirmarContrasenaPasswordField;

    @FXML
    private TextField textFieldParentAffiliateId;

    @FXML
    private void registrarCuenta(ActionEvent event) {
        String cedula = cedulaTextField.getText();
        String nombre = nombreTextField.getText();
        String apellido = apellidoTextField.getText();
        String direccion = dirrecionTextField.getText();
        String correo = correoTextField.getText();
        String contrasena = contrasenaPasswordField.getText();
        String confirmarContrasena = confirmarContrasenaPasswordField.getText();
        String parentAffiliateId = textFieldParentAffiliateId.getText();

        // Validaciones básicas
        if (cedula.isEmpty() || nombre.isEmpty() || apellido.isEmpty() || direccion.isEmpty() ||
                correo.isEmpty() || contrasena.isEmpty() || confirmarContrasena.isEmpty()) {
            mostrarMensaje("Error", "Campos incompletos", "Por favor completa todos los campos.", Alert.AlertType.ERROR);
            return;
        }

        if (!contrasena.equals(confirmarContrasena)) {
            mostrarMensaje("Error", "Contraseñas no coinciden", "Las contraseñas ingresadas no son iguales.", Alert.AlertType.ERROR);
            return;
        }

        try {
//            // Lógica para guardar los datos del afiliado en la base de datos
//            AffiliateData.registrarAfiliado(cedula, nombre, apellido, direccion, correo, contrasena, parentAffiliateId);
//
//            // Mostrar mensaje de éxito
//            mostrarMensaje("Éxito", "Registro exitoso", "La cuenta ha sido registrada con éxito.", Alert.AlertType.INFORMATION);
//
//            // Cerrar la ventana de registro
//            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
//            stage.close();

        } catch (Exception e) {
            e.printStackTrace();
            mostrarMensaje("Error", "Registro fallido", "Ocurrió un error al registrar la cuenta. Inténtalo de nuevo.", Alert.AlertType.ERROR);
        }
    }

    @FXML
    private void salir(ActionEvent event) {
        // Cierra la ventana actual
        Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
        stage.close();
    }

    private void mostrarMensaje(String titulo, String cabecera, String contenido, Alert.AlertType tipo) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setHeaderText(cabecera);
        alerta.setContentText(contenido);
        alerta.showAndWait();
    }
}
