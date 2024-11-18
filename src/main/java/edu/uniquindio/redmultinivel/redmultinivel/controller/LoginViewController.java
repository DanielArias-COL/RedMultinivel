package edu.uniquindio.redmultinivel.redmultinivel.controller;

import edu.uniquindio.redmultinivel.redmultinivel.App;
import javafx.event.ActionEvent;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.input.MouseEvent;
import javafx.stage.Stage;

import java.io.IOException;

public class LoginViewController {
    public void btnCancelar_loginView(ActionEvent actionEvent) {
    }

    public void btnIngresar_loginView(ActionEvent actionEvent) {
    }

    public void mostrarVentanaRecuperarContrasenia(MouseEvent mouseEvent) {
    }

    private void mostrarMensaje(String titulo, String head, String content, Alert.AlertType tipo) {
        Alert alerta = new Alert(null);
        alerta.setTitle(titulo);
        alerta.setHeaderText(head);
        alerta.setContentText(content);
        alerta.setAlertType(tipo);
        alerta.show();
    }

    public void init(App app) {

    }
    public void mostrarPestaniaRegistor(MouseEvent event){
        FXMLLoader loader = new FXMLLoader();
        loader.setLocation(getClass().getResource("/edu/uniquindio/redmultinivel/redmultinivel/registroView.fxml"));

        Parent root = null;
        try {
            root = loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        Scene scene = new Scene(root);
        Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
        stage.setScene(scene);
    }

    public void mostrarVentanaResgitro(MouseEvent mouseEvent) {
        mostrarPestaniaRegistor(mouseEvent);

    }

    }
