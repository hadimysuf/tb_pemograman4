const express = require('express');
const router = express.Router();

const auth = require('../middlewares/authMiddleware');
const userController = require('../controllers/userController');

// All routes here require auth
router.use(auth);

router.get('/', userController.getUsers);
router.get('/me', userController.getMe);
router.put('/me', userController.updateMe);
router.delete('/me', userController.deleteMe);

router.get('/:id', userController.getUserById);
router.put('/:id', userController.updateUser);
router.delete('/:id', userController.deleteUser);

module.exports = router;
