package edu.uniquindio.redmultinivel.redmultinivel.controller;

import edu.uniquindio.redmultinivel.redmultinivel.App;
import edu.uniquindio.redmultinivel.redmultinivel.data.AffiliateData;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

import java.io.IOException;

public class LoginViewController {


    private App app;
    private Stage primaryStage;

    @FXML
    private TextField txtUsuario_loginView;

    @FXML
    private PasswordField txtContraseña_loginView;

    public void btnIngresar_loginView(ActionEvent actionEvent) {

        String email = txtUsuario_loginView.getText();
        String password = txtContraseña_loginView.getText();

        if (email.isEmpty() || password.isEmpty()) {
            //mostrarMensaje("Error", "Campos requeridos", "Por favor ingresa el correo y la contraseña.", Alert.AlertType.ERROR);
            try {
                int idAfiliado = 1;
                mostrarVistaMain(idAfiliado);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }else{
            try {

                //AffiliateData.validarCredenciales(email, password);
                //if(AffiliateData.validarCredenciales(email, password)!=0){
                    //muestra la ventana
                //}else{
                    //muestra el mensaje: las credenciales non coinciden
                //}

                int idAfiliado = 1; //este id lo debe de retornar el método validarCredenciales
                mostrarVistaMain(idAfiliado);

            } catch (IOException e) {
                throw new RuntimeException("Error al cargar la vista principal",e);
            }

        }
    }

    private void mostrarVistaMain(int idAfiliado) throws IOException {
        FXMLLoader loader = new FXMLLoader();
        loader.setLocation(App.class.getResource("main-view.fxml"));

        AnchorPane contenedorMain= (AnchorPane)loader.load();

        Scene escenaMain = new Scene(contenedorMain);

        primaryStage.setScene(escenaMain);

        MainController controller= loader.getController();

        controller.initialize(idAfiliado);
    }

    private void mostrarMensaje(String titulo, String head, String content, Alert.AlertType tipo) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setHeaderText(head);
        alerta.setContentText(content);
        alerta.show();
    }


    public void initialize(App app) {
        this.app = app;
        this.primaryStage = app.getPrimaryStage();
    }


    public void btnCancelar_loginView(ActionEvent actionEvent) {
        System.out.println("Operación cancelada por el usuario.");
        // Cierra la ventana actual
        Stage stage = (Stage) ((Node) actionEvent.getSource()).getScene().getWindow();
        stage.close();
    }

    public void mostrarVentanaRecuperarContrasenia(MouseEvent mouseEvent) {
        // Comentado el código de recuperación de contraseña
    }

    public void mostrarVentanaResgitro(MouseEvent mouseEvent) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/edu/uniquindio/redmultinivel/redmultinivel/registroView.fxml"));
            Parent root = loader.load();

            Stage stage = (Stage) ((Node) mouseEvent.getSource()).getScene().getWindow();
            stage.setScene(new Scene(root));
            stage.setTitle("Registro de Usuario");
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Error cargando la ventana de registro.");
        }
    }


}
