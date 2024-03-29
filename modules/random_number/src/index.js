async function getRandomNumber() {

  await setTimeout(() => {
    console.info('Waiting...');
    console.log('Waiting...')
    console.warn('Waiting...')
    console.error('Waiting...')
  }, 1000);

  return Math.random();
}

export async function handler() {
  console.info('Test function');
  console.log('Test function')

  return {
    statusCode: 200,
    body: JSON.stringify({ message: await getRandomNumber() })
  };
}
