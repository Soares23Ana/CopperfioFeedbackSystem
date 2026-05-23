const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

exports.sendPasswordRecoveryCode = functions.https.onCall(async (data, context) => {
  try {
    const { email } = data;

    if (!email) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Email é obrigatório'
      );
    }

    const normalizedEmail = email.toLowerCase().trim();
    console.log('Procurando email recuperação: ', normalizedEmail);

    // Verifica se o usuário existe no Firestore
    const querySnapshot = await admin
      .firestore()
      .collection('users')
      .where('email', '==', normalizedEmail)
      .limit(1)
      .get();

    if (querySnapshot.empty) {
      console.log('Email não encontrado em "email", buscando em "email_lower"');
      // Busca alternativa com email_lower
      const querySnapshot2 = await admin
        .firestore()
        .collection('users')
        .where('email_lower', '==', normalizedEmail)
        .limit(1)
        .get();

      if (querySnapshot2.empty) {
        console.log('Email não encontrado em nenhum campo para: ', normalizedEmail);
        throw new functions.https.HttpsError(
          'not-found',
          'Usuário não encontrado'
        );
      }
    }

    console.log('Usuário encontrado para email: ', normalizedEmail);

    // Gera código de 5 dígitos
    const verificationCode = Math.floor(Math.random() * 100000)
      .toString()
      .padStart(5, '0');

    // Salva o código no Firestore com timestamp
    await admin.firestore().collection('password_recovery').add({
      email: normalizedEmail,
      code: verificationCode,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 1 * 60 * 1000) // 1 minuto
      ),
      used: false,
    });

    const senderEmail = process.env.SENDGRID_FROM_EMAIL || 'noreply@copperfio.com.br';

    // Prepara e envia o email via SendGrid
    const msg = {
      to: normalizedEmail,
      from: senderEmail,
      subject: 'Copperfio - Código de Recuperação de Senha',
      text: `Olá,

Recebemos uma solicitação para redefinir a senha da sua conta. Use o código de segurança abaixo para confirmar sua identidade no aplicativo:

${verificationCode}

⚠️ Atenção: Este código é válido por 1 minuto. Insira-o no aplicativo o quanto antes para prosseguir.

Se você não solicitou a alteração de senha, pode ignorar este e-mail com segurança. Sua senha atual permanecerá a mesma.

Este e-mail foi enviado pelo endereço ${senderEmail}.

Atenciosamente,

Equipe Copperfio`,
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <style>
              body { font-family: Arial, sans-serif; background-color: #f2f4f8; margin: 0; padding: 0; }
              .container { max-width: 600px; margin: 0 auto; padding: 0 16px 24px; }
              .card { background-color: #ffffff; border-radius: 16px; padding: 24px; box-shadow: 0 12px 28px rgba(0, 0, 0, 0.08); }
              .header { margin-bottom: 24px; }
              .header h1 { margin: 0; font-size: 24px; color: #222222; }
              .body-text { color: #333333; font-size: 16px; line-height: 1.6; margin-bottom: 24px; }
              .code-box { background-color: #eef4fb; border: 1px solid #c7d7f2; border-radius: 16px; padding: 24px; text-align: center; margin: 20px 0; }
              .code-box .code { font-size: 34px; font-weight: 700; color: #1f3d7a; letter-spacing: 4px; }
              .warning { color: #9c1818; font-weight: 700; margin-bottom: 16px; }
              .footer { color: #666666; font-size: 14px; line-height: 1.5; margin-top: 24px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="card">
                <div class="header">
                  <h1>Olá,</h1>
                </div>
                <div class="body-text">
                  Recebemos uma solicitação para redefinir a senha da sua conta. Use o código de segurança abaixo para confirmar sua identidade no aplicativo.
                </div>
                <div class="code-box">
                  <div class="code">${verificationCode}</div>
                </div>
                <div class="warning">
                  ⚠️ Atenção: Este código é válido por 1 minuto. Insira-o no aplicativo o quanto antes para prosseguir.
                </div>
                <div class="body-text">
                  Se você não solicitou a alteração de senha, pode ignorar este e-mail com segurança. Sua senha atual permanecerá a mesma.
                </div>
                <div class="footer">
                  Este e-mail foi enviado pelo endereço ${senderEmail}.<br>
                  Atenciosamente,<br>
                  Equipe Copperfio
                </div>
              </div>
            </div>
          </body>
        </html>
      `,
    };

    await sgMail.send(msg);

    return {
      success: true,
      message: 'Código de recuperação enviado com sucesso',
      codeSent: true
    };
  } catch (error) {
    console.error('Erro ao enviar código de recuperação:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Erro ao enviar email'
    );
  }
});

exports.validatePasswordRecoveryCode = functions.https.onCall(async (data, context) => {
  try {
    const { email, code } = data;

    if (!email || !code) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Email e código são obrigatórios'
      );
    }

    const normalizedEmail = email.toLowerCase().trim();
    console.log('Validando código para email: ', normalizedEmail, ' código: ', code);

    // Busca o código mais recente e válido
    const querySnapshot = await admin
      .firestore()
      .collection('password_recovery')
      .where('email', '==', normalizedEmail)
      .where('code', '==', code)
      .where('used', '==', false)
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();

    if (querySnapshot.empty) {
      console.log('Nenhum código válido encontrado para: ', normalizedEmail);
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código inválido ou expirado'
      );
    }

    const docData = querySnapshot.docs[0];

    // Verifica se expirou
    if (docData.data().expiresAt.toDate() < new Date()) {
      console.log('Código expirado para: ', normalizedEmail);
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código expirado'
      );
    }

    // Marca como usado
    await docData.ref.update({ used: true });
    console.log('Código validado com sucesso para: ', normalizedEmail);

    return {
      success: true,
      message: 'Código validado com sucesso'
    };
  } catch (error) {
    console.error('Erro ao validar código:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Erro ao validar código'
    );
  }
});

exports.resetPasswordWithCode = functions.https.onCall(async (data, context) => {
  try {
    const { email, code, newPassword } = data;

    if (!email || !code || !newPassword) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Email, código e nova senha são obrigatórios'
      );
    }

    const normalizedEmail = email.toLowerCase().trim();
    console.log('Resetando senha para email: ', normalizedEmail);

    const querySnapshot = await admin
      .firestore()
      .collection('password_recovery')
      .where('email', '==', normalizedEmail)
      .where('code', '==', code)
      .where('used', '==', false)
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();

    if (querySnapshot.empty) {
      console.log('Nenhum código de recuperação válido para: ', normalizedEmail);
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código inválido ou expirado'
      );
    }

    const recoveryDoc = querySnapshot.docs[0];
    const recoveryData = recoveryDoc.data();

    if (!recoveryData.expiresAt || recoveryData.expiresAt.toDate() < new Date()) {
      console.log('Código expirado para: ', normalizedEmail);
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código expirado'
      );
    }

    if (newPassword.length < 8) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'A nova senha deve ter pelo menos 8 caracteres'
      );
    }

    const userRecord = await admin.auth().getUserByEmail(normalizedEmail);
    console.log('Atualizando senha para usuário: ', userRecord.uid);
    await admin.auth().updateUser(userRecord.uid, {
      password: newPassword,
    });

    await recoveryDoc.ref.update({
      used: true,
      usedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('Senha resetada com sucesso para: ', normalizedEmail);

    return {
      success: true,
      message: 'Senha atualizada com sucesso',
    };
  } catch (error) {
    console.error('Erro ao redefinir senha com código:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Erro ao redefinir senha'
    );
  }
});
