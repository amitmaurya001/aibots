from demo import app
import os
import traceback
from flask import jsonify, request
from demo.resources.logger import create_logger

logger = create_logger()


class AppError(Exception):
    """All custom Application Exceptions"""
    pass


class BadRequestError(AppError):
    """Custom Bad Request Error Class."""
    code = 400
    description = "Bad Request Error"


class NotFoundResourceError(AppError):
    """Custom NotFoundResourceError Error Class."""
    code = 404
    description = "NotFoundResourceError Error"


@app.errorhandler(AppError)
def handle_error(err):
    response = {"error": err.description, "code": err.code, "message": ""}
    if len(err.args) > 0:
        response["message"] = err.args[0]
    logger.error(f"{err.description}. Status code: {err.code}. Url: {request.url}")
    return jsonify(response), err.code


@app.errorhandler(Exception)
def handle_exception(e):
    error_message = str(e)
    error_message += traceback.format_exc() if \
        os.getenv('FLASK_ENV') == 'development' \
        else ''
    logger.error(f"Critical Error. Status code: 500. Error message: {error_message}. Url: {request.url}")
    return jsonify(
        error=error_message,
        status=500
    ), 500
