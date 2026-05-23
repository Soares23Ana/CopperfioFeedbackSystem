/**
 * Script para normalizar e verificar emails em Firestore
 * Execute com: firebase functions:shell
 * Depois execute: normalizeEmails()
 */

const admin = require('firebase-admin');

async function normalizeEmails() {
  try {
    console.log('Iniciando normalização de emails...');
    
    const db = admin.firestore();
    const usersCollection = await db.collection('users').get();
    
    console.log(`Total de usuários: ${usersCollection.docs.length}`);
    
    let normalized = 0;
    let errors = 0;
    
    for (const doc of usersCollection.docs) {
      const userData = doc.data();
      const email = userData.email || '';
      const normalizedEmail = email.toLowerCase().trim();
      
      console.log(`\n--- Usuário: ${doc.id} ---`);
      console.log(`Email original: "${email}"`);
      console.log(`Email normalizado: "${normalizedEmail}"`);
      console.log(`email_lower: "${userData.email_lower || 'NÃO DEFINIDO'}"`);
      
      // Verifica se precisa normalizar
      if (email !== normalizedEmail || userData.email_lower !== normalizedEmail) {
        try {
          console.log(`✓ Atualizando documento...`);
          await db.collection('users').doc(doc.id).update({
            email: normalizedEmail,
            email_lower: normalizedEmail,
          });
          normalized++;
        } catch (error) {
          console.error(`✗ Erro ao atualizar: ${error.message}`);
          errors++;
        }
      } else {
        console.log(`✓ Já normalizado`);
      }
    }
    
    console.log(`\n=== RESUMO ===`);
    console.log(`Usuários normalizados: ${normalized}`);
    console.log(`Erros: ${errors}`);
    
    // Agora verifica a collection password_recovery
    console.log(`\n\n=== Verificando password_recovery ===`);
    const recoveryCollection = await db.collection('password_recovery').get();
    console.log(`Total de registros: ${recoveryCollection.docs.length}`);
    
    for (const doc of recoveryCollection.docs) {
      const data = doc.data();
      const email = data.email || '';
      console.log(`Email em password_recovery: "${email}"`);
    }
    
  } catch (error) {
    console.error('Erro geral:', error);
  }
}

module.exports = { normalizeEmails };
